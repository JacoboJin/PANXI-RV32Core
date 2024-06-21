module panxi_spsram#(
	parameter DATA_WIDTH = 32,
	parameter ADDR_WIDTH = 10
)(
	input  wire								ACLK	,
	input  wire								CEN		,
	input  wire [ADDR_WIDTH-1:0]			AADDR	,
	input  wire [DATA_WIDTH-1:0]			ADATA_XI,
	input  wire								GWEN	,	// global write enable
	input  wire [DATA_WIDTH-1:0]			AWEN	,	// 
	
	output reg	[DATA_WIDTH-1:0]			ADATA_XO
);

	reg  [ADDR_WIDTH-1:0] addr_hold;
	wire [ADDR_WIDTH-1:0] addr;

	always @(posedge CLK) begin
		if(!CEN) begin
			addr_hold <= AADDR;
		end
	end

	assign addr = CEN ? addr_hold : AADDR;

	wire [DATA_WIDTH-1:0] ram_wen_vec;
	genvar i;
	generate
		for(i=0; i<DATA_WIDTH; i=i+1) begin
			assign ram_wen_vec[i] = !CEN & !WEN[i] & !GWEN;
			panxi_ram #(
				.DATA_WIDTH	(DATA_WIDTH ),
				.ADDR_WIDTH (ADDR_WIDTH )
			)u_panxi_ram(
				.ACLK		(ACLK			),
				.AADDR		(addr			),
				.ADATA_XI	(ADATA_XI[i]	),
				.AWEN		(ram_wen_vec[i] ),
				.ADATA_XO	(ADATA_XO[i]	)
			)
		end
	endgenerate


endmodule
