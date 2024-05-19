// ========================================================= //
//                  Copyright (c) 2023 
//    @ Microelectronics R&D Center, Shanghai University
// ========================================================= //

// For convenience, we will name this processor as PANXI.
`ifndef _CONFIG_V_
`define _CONFIG_V_


`define PANXI_CFG_DEBUG_HAS_JTAG
`define PANXI_CFG_IRQ_NEED_SYNC

// Define addr_size
`define PANXI_CFG_ADDR_SIZE_IS_32

`ifdef PANXI_CFG_ADDR_SIZE_IS_16
    `define PANXI_CFG_ADDR_SIZE   16
`endif
`ifdef PANXI_CFG_ADDR_SIZE_IS_32
    `define PANXI_CFG_ADDR_SIZE   32
`endif
`ifdef PANXI_CFG_ADDR_SIZE_IS_24
    `define PANXI_CFG_ADDR_SIZE   24
`endif


`define PANXI_CFG_REGNUM_IS_32

`define PANXI_CFG_HAS_ITCM
    // 64KB have address 16bits wide
    //   The depth is 64*1024*8/64=8192
`define PANXI_CFG_ITCM_ADDR_WIDTH  16

`define ROM_ADDR_WIDTH      12
`define ROM_START_ADDR      32'h8000



`endif