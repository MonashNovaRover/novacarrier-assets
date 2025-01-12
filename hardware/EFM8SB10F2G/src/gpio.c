/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#include "gpio.h"

volatile uint8_t data pin_state = PIN_STATE_DEFAULT;

void init_portmatch(void)
{
    if (pin_state & PIN_STATE_MASK_PWR_GOOD)
    {
        P0MAT |= P0MASK_PWR_GOOD;
    }
    else
    {
        P0MAT &= ~P0MASK_PWR_GOOD;
    }
    if (pin_state & PIN_STATE_MASK_RESET_N)
    {
        P1MAT |= P1MASK_RESET_N;
    }
    else
    {
        P1MAT &= ~P1MASK_RESET_N;
    }
}

void init_gpio(void)
{
    // Read 8 signal pin state and init pin_state to inactive state.
    // the with-deboucing pins will be debounced after IE_EA is enabled.
    // FORCE_SHUTDOWN actual pin_state will be init when it's enabled in PowerOn().
    pin_state = get_signal_pin_state();
    init_portmatch();
}

// This function cannot be run in main loop, as we only update pin_state after
// port match interrupt serves the pin value changes.
// Updating pin_state in any functions other than port match and init, we may read the wrong pin_state.
uint8_t get_signal_pin_state(void)
{
    uint8_t tmp_pin_state = (pin_state & (PIN_STATE_DEBOUNCE_PIN_MASK | PIN_STATE_MASK_FORCE_SHUTDOWN_N));
    // The pins need to be debounced and FORCE_SHUTDOWN will be updated in timer2 and comparator
    if (PWR_GOOD)
    {
        tmp_pin_state |= PIN_STATE_MASK_PWR_GOOD;
    }
    if (RESET_N)
    {
        tmp_pin_state |= PIN_STATE_MASK_RESET_N;
    }
    return tmp_pin_state;
}

void refresh_pin_state_force_shutdown(void)
{
    // Read from CMP0CN0_CPOUT register, because of comparator setting, FORCE_SHUTDOWN is skipped by crossbar
    // CMP0CN0_CPOUT = 0, positive hysteresis (FORCE_SHUTDOWN) < negative hysteresis (VDD/2)
    // CMP0CN0_CPOUT = 1, positive hysteresis (FORCE_SHUTDOWN) > negative hysteresis (VDD/2)
    if (CMP0CN0 & CMP0CN0_CPOUT__BMASK)
    {
        pin_state |= PIN_STATE_MASK_FORCE_SHUTDOWN_N;
    }
    else
    {
        pin_state &= ~PIN_STATE_MASK_FORCE_SHUTDOWN_N;
    }
}
