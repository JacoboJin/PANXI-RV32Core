`timescale 1ps/1ps
`include "../defines.v"

module panxi_pc(
    input  wire                             clk         ,
    input  wire                             rst         ,

    // from jmp
    input  wire  [`PANXI_DW-1:0]            jmp_addr_xi ,
    input  wire                             jmp_en_xi   ,
    input  wire  [`HOLD_WIDTH-1:0]          hold_flag_xi,
    
    //from jtag
    input  wire                             rst_jtag_xi ,

    // to if
    output wire  [`PANXI_DW-1:0]            inst_addr_xo
);

    reg [`PANXI_DW-1:0] pc_ptr;

    // sync design
    always @(posedge clk) begin
        // reset pc ptr
        if(rst == 1'b1 || rst_jtag_xi == 1'b1) begin
            pc_ptr <= 32'h0;
        end
        // jump
        else if(jmp_en_xi == 1'b1) begin
            pc_ptr <= jmp_addr_xi;
        end
        // hold
        else if(hold_flag_xi == `HOLD_PC) begin
            pc_ptr <= pc_ptr;
        end
        // pc+4
        else begin
            pc_ptr <= pc_ptr + 32'd4;
        end
    end

    assign inst_addr_xo = pc_ptr;

endmodule