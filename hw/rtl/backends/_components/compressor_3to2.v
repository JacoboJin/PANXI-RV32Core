module comp_3to2 #(
	parameter NUM = 16
)
(
	input [NUM-1:0] a,
	input [NUM-1:0] b,
	input [NUM-1:0] c,
	output [NUM-1:0] sum,
	output [NUM-1:0] carry
);

assign sum = a ^ b ^ c;
assign carry = a & b | (a | b) & c;

endmodule