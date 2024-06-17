`timescale 1ps/1ps
`include "../defines.v"

module panxi_if(
    // from pc
    input  wire  [`PANXI_DW-1:0]            inst_addr_xi,
    
    // from icache
    input  wire                             icache_rdy  ,  // I-cache ready signal
    input  wire                             icache_hit  ,  // I-cache hit signal
    input  wire  [`]
    // to icache

    // to if_id

    // to ctrl
);

endmodule