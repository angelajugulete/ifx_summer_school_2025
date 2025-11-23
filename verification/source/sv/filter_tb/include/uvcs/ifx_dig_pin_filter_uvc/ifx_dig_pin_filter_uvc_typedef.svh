/******************************************************************************
 * (C) Copyright 2020 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE:
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 *******************************************************************************/

typedef enum int {
    FILT_SYNC_SINGLE = 0,  // Single state synchronizer
    FILT_SYNC_DOUBLE = 1   // Double state synchronizer
} filt_sync_stage_t; // selects number of filter synchronization stages

typedef enum int {
    FILT_ASYNC_RESET = 0, // Asynchronous filter reset
    FILT_SYNC_RESET  = 1  // Synchronous filter reset
} filt_reset_t; // selects type of filter reset


typedef enum int {
    FILT_FALLING  = 0,  // Falling edge filter
    FILT_RISING   = 1,  // Rising edge filter
    FILT_BOTH     = 2,  // Both edges filter
    FILT_DISABLED = 3   // Filter is disabled - input changes are not propagated to the output
} filt_type_t; // FIlter type: rising, falling, or both edges

typedef enum int {
    FILT_FALL_EDGE = 0, // Falling edge filter level
    FILT_RISE_EDGE = 1  // Rising edge filter level
} filt_edge_t; // selects filter level for rising or falling edge

typedef enum int {
    FILT_INVALID = 0,  // Filter is invalid
    FILT_VALID   = 1,  // Filter is valid
    FILT_NONE    = 2   // no filtering is applied on the current edge
} filt_validity_t; // selects filter validity

typedef enum int {
    FILT_DRV_LEVEL   = 0,  // drive a level on a bus
    FILT_DRV_TOGGLE  = 1,  // toggle the level on the bus
    FILT_DRV_VALID   = 2,  // drive the level for a valid duration on the bus
    FILT_DRV_INVALID = 3,  // drive the level for an invalid duration on the bus
    FILT_DRV_GLITCH  = 4,  // drive a glitch on the bus - shorter than 1 period and in between clock edges
    FILT_DRV_PULSE   = 5   // drive a pulse of a given length on the bus
} filt_drive_t; // selects filter drive type