`include "cla_hybird.v"
`include "cla_BK.v"

module cla_adder #(
	parameter NUM = 32,
	parameter ST = "hybird"
)(
	input      [NUM-1:0] a,
	input      [NUM-1:0] b,
	output     [NUM-1:0] s
);

generate
	if (ST == "hybird") begin
		cla_Hybird #(
			.NUM(NUM)
		) CLA (
			.a(a),
			.b(b),
			.ci(0),
			.s(s),
			.co()
		);
	end
	else begin
		cla_BK #(
			.NUM(NUM)
		) CLA (
			.a(a),
			.b(b),
			.ci(0),
			.s(s),
			.co()
		);
	
	end

endgenerate

endmodule