/*
 * Copyright (c) 2019-2020, NVIDIA CORPORATION.  All rights reserved.
 *
 * NVIDIA CORPORATION and its licensors retain all intellectual property
 * and proprietary rights in and to this software, related documentation
 * and any modifications thereto.  Any use, reproduction, disclosure or
 * distribution of this software and related documentation without an express
 * license agreement from NVIDIA CORPORATION is strictly prohibited.
 */

#ifndef INC_POWER_H_
#define INC_POWER_H_

typedef enum
{
    NONE = 0,
    INIT,
    POWERING_ON_PMIC,
    POWERING_ON_WAIT_FOR_PWR_GOOD,
    POWERING_OFF_VIN_PWR_ON,
    RESET_IGNORE_PWR_GOOD,
    POWER_EVENT_ERROR
} power_event_t;

// Functions prototype
void init_power(void);
void PowerOn(void);
void PoweringOn(void);
void PoweringOff(void);
void PowerOff(void);
void Reset(void);

// Variables
extern void (*run_power_state)(void);
extern volatile bit timer1_flag; // timer1 interrupt flag
extern volatile bit timer0_flag;
extern volatile power_event_t power_event;
extern bit power_off_state;

#endif /* INC_POWER_H_ */
