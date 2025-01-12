/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#include "timer.h"
#include "power.h"
#include "gpio.h"

volatile power_event_t power_event = NONE;
static bit save_ie_ea;
bit power_off_state = 1; // Flag to optimize checking the power off state

void enter_power_state(void (*funcptr)(void))
{
    run_power_state = funcptr;
    power_event = INIT;
}

void init_power(void)
{
    enter_power_state(PowerOff);
}

void clear_flag_and_start_timer1(unsigned int delay_ms)
{
    if (delay_ms == TIMER1_10MS)
    {
        TH1 = TIMER1_10MS_RELOAD_HIGH;
        TL1 = TIMER1_10MS_RELOAD_LOW;
    }
    else if (delay_ms == TIMER1_100MS)
    {
        TH1 = TIMER1_100MS_RELOAD_HIGH;
        TL1 = TIMER1_100MS_RELOAD_LOW;
    }
    else if (delay_ms == TIMER1_80MS)
    {
        TH1 = TIMER1_80MS_RELOAD_HIGH;
        TL1 = TIMER1_80MS_RELOAD_LOW;
    }
    else
    {
        TH1 = 0xFF;
        TL1 = 0xFF;
    }

    timer1_flag = 0;
    TCON_TR1 = 1; // start timer1
}

void PowerOn(void)
{
    static unsigned int pwr_btn_sec_counter = 0;
    static bit reset_n_released = 0;

    if (power_event == INIT)
    {
        power_event = NONE; // clear power event
        // Enable and clear comparator interrupt flags in case of triggering after re-enabled
        CMP0CN0 &= ~CMP0CN0_CPFIF__FALLING_EDGE;
        refresh_pin_state_force_shutdown(); // refresh pin_state with FORCE_SHUTDOWN's latest pin state
        EIE1 |= EIE1_ECP0__ENABLED;
        TCON_TR0 = 0;
        timer0_flag = 0;
        reset_n_released = 0;
        pwr_btn_sec_counter = 0;
        PMIC_EN0 = 1;
        VIN_PWR_ON = 1;
    }

    save_ie_ea = IE_EA;
    IE_EA = 0;
    // To avoid going to reset state repeatedly while long press reset btn,
    // use this flag, only go to reset state after reset btn is released
    if ((pin_state & PIN_STATE_MASK_RESET_N))
    {
        reset_n_released = 1;
    }

    if ((pin_state & PIN_STATE_MASK_PWR_BTN_N) == 0)
    {
        if (timer0_flag == 1)
        {
            pwr_btn_sec_counter++;
        }
        if (TCON_TR0 == 0)
        {
            // In case other interrupts trigger this function multiple times
            timer0_flag = 0;
            TH0 = TIMER0_100MS_RELOAD_HIGH;
            TL0 = TIMER0_100MS_RELOAD_LOW;
            TCON_TR0 = 1; // start timer0
        }
    }
    else
    {
        pwr_btn_sec_counter = 0;
        TCON_TR0 = 0; // stop timer0
    }

    // 10s long press / 100ms = Timer0 expires 100 times
    if ((pwr_btn_sec_counter >= 100) ||
        ((pin_state & (PIN_STATE_MASK_FORCE_SHUTDOWN_N | PIN_STATE_MASK_PWR_GOOD)) !=
         (PIN_STATE_MASK_FORCE_SHUTDOWN_N | PIN_STATE_MASK_PWR_GOOD)))
    {
        // If PWR_BTN_N asserted for more than 10s, FORCE_SHUTDOWN_N is asserted or PWR_GOOD drops, power off
        enter_power_state(PoweringOff);
    }
    else if (((pin_state & PIN_STATE_MASK_RESET_N) == 0) && reset_n_released)
    {
        enter_power_state(Reset);
    }
    else
    {
        // do nothing
    }
    IE_EA = save_ie_ea;
}

void PoweringOn(void)
{
    if (power_event == INIT)
    {
        power_event = NONE; // clear power event
    }

    if (power_event == NONE)
    {
        VIN_PWR_ON = 1;
        clear_flag_and_start_timer1(TIMER1_POWER_ON_PMIC);
        power_event = POWERING_ON_PMIC;
    }
    else if (power_event == POWERING_ON_PMIC)
    {
        if (timer1_flag)
        {
            PMIC_EN0 = 1;
            // Set up timer for POWERING_ON_WAIT_FOR_PWR_GOOD
            clear_flag_and_start_timer1(TIMER1_POWER_ON_WAIT_PWR_GOOD);
            power_event = POWERING_ON_WAIT_FOR_PWR_GOOD;
        }
    }
    else if (power_event == POWERING_ON_WAIT_FOR_PWR_GOOD)
    {
        if (timer1_flag || (pin_state & PIN_STATE_MASK_PWR_GOOD))
        { // timer expired or interrupted when PWR_GOOD goes high
            timer1_flag = 0;
            TCON_TR1 = 0; // stop timer1

            if (pin_state & PIN_STATE_MASK_PWR_GOOD)
            {
                enter_power_state(PowerOn);
            }
            else
            {
                // Failed to power on: waited for 10ms, PWR_GOOD is still de-asserted
                enter_power_state(PoweringOff);
            }
        }
    }
    else
    {
        // do nothing
    }
}

void PowerOff(void)
{
    static bit pwr_btn_n_released = 0;
    static bit acok_deasserted = 0;

    if (power_event == INIT)
    {
        power_event = NONE; // clear power event
        power_off_state = 1; // set power off state flag
        pwr_btn_n_released = 0;
        acok_deasserted = 0;
        PMIC_EN0 = 0;
        VIN_PWR_ON = 0;
        timer1_flag = 0;
    }

    save_ie_ea = IE_EA;
    IE_EA = 0;
    if ((pin_state & PIN_STATE_MASK_ACOK) == 0)
    {
        // Only if ACOK is deasserted, the system can be powered on again
        // Otherwise the system will be turn on right after turning off
        acok_deasserted = 1;
    }

    if (pin_state & PIN_STATE_MASK_PWR_BTN_N)
    {
        // Only if PWR_BTN_N is released, the system can be powered on again
        pwr_btn_n_released = 1;
    }

    //  if ACOK, or PWR_BTN_N is active and released before, powering on
    if ((pwr_btn_n_released && ((pin_state & PIN_STATE_MASK_PWR_BTN_N) == 0)) ||
        (acok_deasserted && (pin_state & PIN_STATE_MASK_ACOK)))
    {
        enter_power_state(PoweringOn);
        power_off_state = 0; // clear flag when exiting power off state
    }
    IE_EA = save_ie_ea;
}

void PoweringOff(void)
{
    if (power_event == INIT)
    {
        power_event = NONE; // clear power event
        EIE1 &= ~EIE1_ECP0__ENABLED; // Disable comparator interrupt until entering power on state
    }

    if (power_event == NONE)
    {
        PMIC_EN0 = 0;
        // Set up timer for POWERING_OFF_VIN_PWR_ON
        clear_flag_and_start_timer1(TIMER1_POWER_OFF_VIN);
        power_event = POWERING_OFF_VIN_PWR_ON;
    }
    else if (power_event == POWERING_OFF_VIN_PWR_ON)
    {
        if (timer1_flag)
        {
            timer1_flag = 0;
            VIN_PWR_ON = 0;
            enter_power_state(PowerOff);
        }
    }
    else
    {
        // do nothing
    }
}

void Reset(void)
{
    if (power_event == INIT)
    {
        power_event = NONE; // clear power event
    }

    if (power_event == NONE)
    {
        // exit reset state after 100ms to ignore PWR_GOOD and FORCE_SHUTDOWN while Tegra is being reset
        clear_flag_and_start_timer1(TIMER1_RESET);
        power_event = RESET_IGNORE_PWR_GOOD;
    }
    else if (power_event == RESET_IGNORE_PWR_GOOD)
    {
        if (timer1_flag == 1)
        {
            enter_power_state(PowerOn);
        }
    }
    else
    {
        // do nothing
    }
}
