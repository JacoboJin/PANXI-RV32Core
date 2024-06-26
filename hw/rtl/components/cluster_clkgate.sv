module cluster_clkgate (
    input  logic         clk_i     ,
    input  logic         en_i      ,
    input  logic         test_en_i ,
    output logic         clk_o
);
    `ifdef PANXI_FPGA_EMUL
        assign clk_o = clk_i;
    `else
        logic clk_en;
        always_latch begin : clkgate
            if (clk_i == 1'b0) begin
                clk_en <= en_i | test_en_i ;
            end
        end

        assign clk_o = clk_i & clk_en;
    `endif
    
endmodule