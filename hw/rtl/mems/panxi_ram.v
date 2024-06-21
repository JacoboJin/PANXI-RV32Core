module panxi_ram#(
	parameter	DATA_WIDTH = 2	,
	parameter	ADDR_WIDTH = 2
)(
	input  wire							ACLK		, // clock
	input  wire [ADDR_WIDTH-1:0]		AADDR		, // address
	input  wire	[DATA_WIDTH-1:0]		ADATA_XI	, // data in
	input  wire							AWEN			, // write enable, active high
	output reg	[DATA_WIDTH-1:0]		ADATA_XO	  // data out
);

	// MEM
	localparam MEMDEPTH = 2**ADDR_WIDTH;
	reg [DATA_WIDTH-1:0] mems [MEMDEPTH-1:0];


	always @(posedge ACLK) begin
		if(AWEN) begin
			mems[AADDR] <= ADATA_XI;
			ADATA_XO    <= ADATA_XI;
		end
		else begin
			ADATA_XO    <= mems[AADDR];
		end
	end

endmodule
