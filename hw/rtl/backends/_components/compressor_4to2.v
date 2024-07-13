module comp_4to2 #(
	parameter NUM = 16
)(
	input [NUM-1:0] a,
	input [NUM-1:0] b,
	input [NUM-1:0] c,
	input [NUM-1:0] d,
	output [NUM:0] sum,
	output [NUM:0] carry
);

wire [NUM:0] e;
wire [NUM-1:0] cy, s;
assign e[0] = 0;
assign sum = {e[NUM], s};
assign carry = {cy, 1'b0};

genvar i;
generate
	for (i = 0; i < NUM; i=i+1) begin
        assign s[i] = a[i] ^ b[i] ^ c[i] ^ d[i] ^ e[i];
        assign e[i+1] = b[i] & c[i] | b[i] & d[i] | c[i] & d[i];
        assign cy[i] = ~(a[i] ^ b[i] ^ c[i] ^ d[i]) & a[i] | e[i] & (a[i] ^ b[i] ^ c[i] ^ d[i]);
	end
endgenerate


endmodule
