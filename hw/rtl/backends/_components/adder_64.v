`include "cla_adder.v"

module adder_64(
    input clk,
    input [63:0] a,
    input [63:0] b,
    input sign,
    output reg [63:0] s,
    output reg overflow
);

wire [63:0] mid;
wire [4:0] carry;

assign carry[0] = 1'b0;

genvar i;
generate
    for(i=0; i < 4; i=i+1) begin
        cla_BK #(
            .NUM(16)
        ) cla_1 (
            .a(a[i*16+:16]),
            .b(b[i*16+:16]),
            .ci(carry[i]),
            .s(mid[i*16+:16]),
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
        if(a[63] & b[63]) begin
            overflow <= ~mid[63];
            s <= mid;
        end
        else if(~(a[63] | b[63])) begin
            overflow <= mid[63];
            s <= {1'b0, mid[62:0]};
        end
        else begin
            overflow <= 0;
            s <= mid;
        end
    end
end

endmodule