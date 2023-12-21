// ========================================================= //
//                  Copyright (c) 2023 
//    @ Microelectronics R&D Center, Shanghai University
// ========================================================= //

`include "l524_defines.v"

module l524_clkgate (
    input       clk_i,
    input       test_mode,
    input       clk_en,
    output      clk_o
);

`ifdef FPGA_SOURCE
    // In the FPGA, the clock gating is just pass through
    assign clk_o = clk_i;
`endif

`ifndef FPGA_SOURCE
    reg ena;

    // describe a latch deliberately
    always@(*) begin
        if (!clk_i) begin
            ena = (clk_en | test_mode);
        end
    end

    // a combination circuit to declare clock gate
    assign clk_o = ena & clk_i;

`endif

endmodule 