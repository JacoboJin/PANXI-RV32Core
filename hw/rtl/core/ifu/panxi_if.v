`timescale 1ps/1ps
`include "../defines.v"

module panxi_if(
    // from pc
    input  wire  [`PANXI_DW-1:0]        inst_addr_xi    ,
    
    // from icache
    input  wire                         icache_rdy      ,  // I-cache ready signal
    input  wire                         icache_hit      ,  // I-cache hit signal
    input  wire  [`PANXI_DW-1:0]        icache_data_rd  ,
    
    // to icache
    output wire  [11:0]                 icache_req_addr ,
    output wire                         icache_req_vld  ,
    output wire                         icache_req_rw   ,
    
    // to if_id
    output wire  [`PANXI_DW-1:0]        inst_addr_xo    ,
    output wire  [`PANXI_DW-1:0]        inst_xo         , 

    // to ctrl
    output wire  [`HOLD_WIDTH-1:0]      hold_flag_xo       // if state hold flag 
);



endmodule