module panxi_dff_set #(
    parameter DW = 64
)(
    input  logic                clk,
    input  logic                rst,
    input  logic [1:0]          hold_en,
    input  logic [DW-1:0]       set_data,
    input  logic [DW-1:0]       data_in,
    output logic [DW-1:0]       data_out
);

    always_ff (posedge clk) begin
        if (rst || hold_en == 2'b01) begin
            data_out <= set_data;
        end
        else if (hold_en == 2'b10) begin
            data_out <= data_out;
        end
        else begin
            data_out <= data_in;
        end
    end

endmodule