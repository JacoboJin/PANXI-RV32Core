module gated_clk(
	input  wire				clk_xi		,
	input  wire				global_en	,
	input  wire				module_en	,
	input  wire				local_en	,
	input  wire				external_en	,
	input  wire				pad_scan_en ,

	output wire				clk_xo
);

	wire	clk_en_latch;
	wire	SE;

	assign	clk_en_latch	= (global_en && (module_en || local_en)) || external_en;
	assign	SE				= pad_scan_en;

	assign	clk_xo			= clk_en_latch ? clk_xi : 1'b0; 


endmodule
