/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#ifndef INC_GPIO_H_
#define INC_GPIO_H_

#include <SI_EFM8SB1_Register_Enums.h>    // SFR declarations

// P0
#define PWR_BTN_N           P0_B0
#define VOL_UP_N            P0_B2
#define ACOK                P0_B6
#define PWR_GOOD            P0_B7

// P1
#define RESET_N             P1_B1
#define FORCE_SHUTDOWN_N    P1_B0
#define VIN_PWR_ON          P1_B3
#define PMIC_EN0            P1_B5
#define PB_BUFF_N           P1_B6
#define FORCE_RECOVERY_N    P1_B7

// Port match mask
#define P1MASK_RESET_N              P1_B1__BMASK
#define P0MASK_ACOK                 P0_B6__BMASK
#define P0MASK_PWR_GOOD             P0_B7__BMASK
#define P0MASK_PWR_BTN_N            P0_B0__BMASK
#define P0MASK_VOL_UP_N             P0_B2__BMASK
#define P1MASK_FORCE_SHUTDOWN_N     P1_B0__BMASK

#define DEBOUNCE_STATE_MASK         (uint8_t)0xE0
#define DEBOUNCE_STATE_LOW_MATCH    (uint8_t)0xE0
#define DEBOUNCE_STATE_HIGH_MATCH   (uint8_t)0xFF

// Pin state mask
#define PIN_STATE_MASK_PWR_BTN_N        0x01
#define PIN_STATE_MASK_VOL_UP_N         0x04
#define PIN_STATE_MASK_FORCE_SHUTDOWN_N 0x10
#define PIN_STATE_MASK_RESET_N          0x20
#define PIN_STATE_MASK_PWR_GOOD         0x40
#define PIN_STATE_MASK_ACOK             0x80

#define PIN_STATE_DEBOUNCE_PIN_MASK     (PIN_STATE_MASK_ACOK | PIN_STATE_MASK_VOL_UP_N | PIN_STATE_MASK_PWR_BTN_N)
#define PIN_STATE_NO_DEBOUNCE_PIN_MASK  (~PIN_STATE_DEBOUNCE_PIN_MASK)

// init pins that need debouncing to their inactive state
// ACOK(Low), VOL_UP_N(High), PWR_BTN_N(High)
#define PIN_STATE_DEFAULT               (PIN_STATE_DEBOUNCE_PIN_MASK & (~PIN_STATE_MASK_ACOK))

void init_gpio(void);
uint8_t get_signal_pin_state(void);
void refresh_pin_state_force_shutdown(void);

extern volatile uint8_t pin_state;

#endif /* INC_GPIO_H_ */
