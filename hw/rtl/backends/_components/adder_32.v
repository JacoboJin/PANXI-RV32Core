`include "cla_adder.v"

module adder_32(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input sign,
    output reg [31:0] s,
    output reg overflow
);

wire [31:0] mid;
wire [4:0] carry;

assign carry[0] = 1'b0;

genvar i;
generate
    for(i=0; i < 4; i=i+1) begin
        cla_BK #(
            .NUM(8)
        ) cla_1 (
            .a(a[i*8+:8]),
            .b(b[i*8+:8]),
            .ci(carry[i]),
            .s(mid[i*8+:8]),
            .co(carry[i+1])
        );
    end
endgenerate

always @(posedge clk) begin
    if(!sign) begin
        overflow <= carry[4];
        s <= mid;
    end
    else begin
        if(a[31] & b[31]) begin
            overflow <= ~mid[31];
            s <= mid;
        end
        else if(~(a[31] | b[31])) begin
            overflow <= mid[31];
            s <= {1'b0, mid[30:0]};
        end
        else begin
            overflow <= 0;
            s <= mid;
        end
    end
end

endmodule