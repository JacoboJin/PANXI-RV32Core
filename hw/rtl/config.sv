// ========================================================= //
//                  Copyright (c) 2023 
//    @ Microelectronics R&D Center, Shanghai University
// ========================================================= //

// For convenience, we will name this processor as PANXI.
`ifndef _CONFIG_V_
`define _CONFIG_V_

`define RISCV

`ifndef PANXI_FPGA_EMUL
`ifdef SYNTHESIS
`define ASIC
`endif
`endif


`define ROM_ADDR_WIDTH      12
`define ROM_START_ADDR      32'h8000

`ifndef SYNTHESIS
// `define DATA_STALL_RANDOM
// `define INSTR_STALL_RANDOM
`endif

`endif