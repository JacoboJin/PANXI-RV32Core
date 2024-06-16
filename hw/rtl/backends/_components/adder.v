module adder #(
	parameter NUM = 32
)(
	input clk,
	input [NUM-1:0] a,
	input [NUM-1:0] b,
	input sign,
	output reg [NUM-1:0] s,
	output reg overflow
);

	wire [NUM-1:0] mid;
	wire carry;

	cla_hybrid #(
		.NUM(NUM)
	) CLA (
		.a(a),
		.b(b),
		.ci(0),
		.s(mid),
		.co(carry)
    );

	always @(posedge clk) begin
		s <= mid;
	end

	always @(posedge clk) begin
		if (sign) begin
			if (a[NUM-1] & b[NUM-1]) begin
				overflow <= ~mid[NUM-1];
			end
			else if (~(a[NUM-1] | b[NUM-1])) begin
				overflow <= mid[NUM-1];
			end
			else begin
				overflow <= 0;
			end
		end
		else begin
			overflow <= carry;
		end
	end

endmodule