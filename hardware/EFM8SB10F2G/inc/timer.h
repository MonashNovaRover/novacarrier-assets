/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#ifndef INC_TIMER_H_
#define INC_TIMER_H_

// Timer 0: PWR_BTN_N long press
// Timer 1: delays while powering on/off
// Timer 2: debouncing

#define SYSCLK                      20000000L

// Timer 0/1
#define TIMER_PRESCALER             48
#define TIMER_TICKS_PER_MS          SYSCLK/TIMER_PRESCALER/1000
#define TIMER_TICKS_PER_SEC         SYSCLK/TIMER_PRESCALER

#define TIMER_HIGH_BYTE(x)          (uint8_t)(((-x) & 0xFF00) >> 8)
#define TIMER_LOW_BYTE(x)           (uint8_t)((-x) & 0x00FF)

// 10 ms
#define TIMER1_10MS                 10
#define TIMER1_10MS_RELOAD_HIGH     TIMER_HIGH_BYTE(TIMER_TICKS_PER_MS*TIMER1_10MS)
#define TIMER1_10MS_RELOAD_LOW      TIMER_LOW_BYTE(TIMER_TICKS_PER_MS*TIMER1_10MS)

// 100 ms
#define TIMER1_100MS                100
#define TIMER1_100MS_RELOAD_HIGH    TIMER_HIGH_BYTE(TIMER_TICKS_PER_MS*TIMER1_100MS)
#define TIMER1_100MS_RELOAD_LOW     TIMER_LOW_BYTE(TIMER_TICKS_PER_MS*TIMER1_100MS)

#define TIMER0_100MS_RELOAD_HIGH    TIMER1_100MS_RELOAD_HIGH
#define TIMER0_100MS_RELOAD_LOW     TIMER1_100MS_RELOAD_LOW

// 80 ms
#define TIMER1_80MS                 80
#define TIMER1_80MS_RELOAD_HIGH     TIMER_HIGH_BYTE(TIMER_TICKS_PER_MS*TIMER1_80MS)
#define TIMER1_80MS_RELOAD_LOW      TIMER_LOW_BYTE(TIMER_TICKS_PER_MS*TIMER1_80MS)

// Timer 2/3
#define TIMER2_PRESCALER            12 // timer 2
#define TIMER2_TICKS_PER_MS         SYSCLK/TIMER2_PRESCALER/1000 // 208.33
#define TIMER3_TICKS_PER_10US       TIMER2_TICKS_PER_MS/100      // 2.08

// 5ms timer ticks
#define TIMER2_DEBOUNCE_MS_PER_CYCLE    5
#define TIMER2_DEBOUNCE_RELOAD_HIGH     TIMER_HIGH_BYTE(TIMER2_TICKS_PER_MS*TIMER2_DEBOUNCE_MS_PER_CYCLE)
#define TIMER2_DEBOUNCE_RELOAD_LOW      TIMER_LOW_BYTE(TIMER2_TICKS_PER_MS*TIMER2_DEBOUNCE_MS_PER_CYCLE)

// Timer3: pin_state_change kick
#define TIMER3_KICK_40US                4
#define TIMER3_KICK_RELOAD_HIGH         TIMER_HIGH_BYTE(TIMER3_TICKS_PER_10US*TIMER3_KICK_40US)
#define TIMER3_KICK_RELOAD_LOW          TIMER_LOW_BYTE(TIMER3_TICKS_PER_10US*TIMER3_KICK_40US)

#define TIMER1_POWER_ON_PMIC            TIMER1_80MS
#define TIMER1_POWER_ON_WAIT_PWR_GOOD   TIMER1_100MS
#define TIMER1_POWER_OFF_VIN            TIMER1_10MS
#define TIMER1_RESET                    TIMER1_100MS

#endif /* INC_TIMER_H_ */
