`include "../defines.v"

module panxi_pc(
    input  wire                             clk         ,
    input  wire                             rst         ,

    // from jmp
    input  wire  [`PANXI_DW-1:0]            jmp_addr_xi ,
    input  wire                             jmp_en_xi   ,
    input  wire  [`HOLD_WIDTH-1:0]          hold_flag_xi,
    
    //from jtag
    input  wire                            rst_jtag_xi ,

    // to if
    output reg  [`PANXI_DW-1:0]             pc_xo
);
    // sync design
    always @(posedge clk) begin
        // reset pc ptr
        if(rst == 1'b1 || rst_jtag_xi == 1'b1) begin
            pc_xo <= 32'h0;
        end
        // jump
        else if(jmp_en_xi == 1'b1) begin
            pc_xo <= jmp_addr_xi;
        end
        // hold
        else if(hold_flag_xi == `HOLD_PC) begin
            pc_xo <= pc_xo;
        end
        // pc+4
        else begin
            pc_xo <= pc_xo + 32'd4;
        end
    end

endmodule