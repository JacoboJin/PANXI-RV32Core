// ========================================================= //
//                  Copyright (c) 2023 
//    @ Microelectronics R&D Center, Shanghai University
// ========================================================= //

`ifndef _CONFIG_V_
`define _CONFIG_V_

// For convenience, we will name this processor as L524.


// `define L524_CFG_ADDR_SIZE_IS_16
// `define L524_CFG_ADDR_SIZE_IS_64
`define L524_CFG_ADDR_SIZE_IS_32

`ifdef L524_CFG_ADDR_SIZE_IS_16
    `define ADDR_SIZE   16
`endif
`ifdef L524_CFG_ADDR_SIZE_IS_32
    `define ADDR_SIZE   32
`endif
`ifdef L524_CFG_ADDR_SIZE_IS_64
    `define ADDR_SIZE   64
`endif


// `define L524_CFG_SUPPORT_MSCRATCH
`define L524_CFG_SUPPORT_MCYCLE_MINSTRET

`define E203_CFG_REGNUM_IS_32
/////////////////////////////////////////////////////////////////
`define E203_CFG_HAS_ITCM
    // 64KB have address 16bits wide
    //   The depth is 64*1024*8/64=8192
`define E203_CFG_ITCM_ADDR_WIDTH  16



`endif