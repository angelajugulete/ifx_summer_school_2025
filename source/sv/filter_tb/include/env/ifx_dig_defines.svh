/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE: ifx_dig_defines
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 *******************************************************************************/

//=========================================================================
// Environment and tests.
//-------------------------------------------------------------------------
//=========================================================================


/////////////////////  Add your defines below ////////////////////////////////


// Filter related defines
`define FILT_NB 16 // the number of configured filters in the design

//Registers and data bus defines
`define DWIDTH         8 // Data bus width
`define NO_CFG_REGS    `FILT_NB // we have one configuration register for each filter
`define NO_STATUS_REGS ((`FILT_NB%8 == 0) ? (`FILT_NB/8) : (`FILT_NB/8 + 1)) // we have one status register for 8 filters
`define AWIDTH         $clog2((`NO_CFG_REGS + `NO_STATUS_REGS)) // Address bus width, dependend on the number of registers

// TODO defines for registers?


/// Utilities
`define WAIT_NS(TIME) #(``TIME``*1ns);
`define WAIT_US(TIME) #(``TIME``*1us);
`define WAIT_MS(TIME) #(``TIME``*1ms);
`define WAIT_PS(TIME) #(``TIME``*1ps);

`define RAND_1BIT \
1'($urandom_range(0,1))
`define RAND_2BIT \
2'($urandom_range(0,3))
`define RAND_3BIT \
3'($urandom_range(0,7))
`define RAND_4BIT \
4'($urandom_range(0,15))
`define RAND_5BIT \
5'($urandom_range(0,31))
`define RAND_6BIT \
6'($urandom_range(0,63))
`define RAND_7BIT \
7'($urandom_range(0,127))
`define RAND_8BIT \
8'($urandom_range(0,255))

`define RAND_2BIT_NON0 \
2'($urandom_range(1,3))
`define RAND_3BIT_NON0 \
3'($urandom_range(1,7))
`define RAND_4BIT_NON0 \
4'($urandom_range(1,15))
`define RAND_5BIT_NON0 \
5'($urandom_range(1,31))
`define RAND_6BIT_NON0 \
6'($urandom_range(1,63))
`define RAND_7BIT_NON0 \
7'($urandom_range(1,127))
`define RAND_8BIT_NON0 \
8'($urandom_range(1,255))

`define TEST_INFO(MSG)\
`uvm_info("TEST", $sformatf("\n\n[TEST_INFO][%.2fus]:\n\t %s\n\n", $time/1us, ``MSG``), UVM_NONE);\