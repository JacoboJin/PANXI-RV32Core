module panxi_spsram_1024x32(
	input  wire					ACLK	,
	input  wire					CEN		,
	input  wire [9:0]			AADDR	,
	input  wire [31:0]			ADATA_XI,
	input  wire					GWEN	,	// global write enable
	input  wire [31:0]			AWEN	,	// 
	
	output reg	[31:0]			ADATA_XO
);

    panxi_spsram #(
        .DATA_WIDTH (32),
        .ADDR_WIDTH (10)
    ) u_panxi_spram_1024x32(
	    .ACLK	    (ACLK       ),
	    .CEN		(CEN        ),
	    .AADDR	    (AADDR      ),
	    .ADATA_XI   (ADATA_XI   ),
	    .GWEN	    (GWEN       ),	// global write enable
	    .AWEN	    (AWEN       ),	// 
	
	    .ADATA_XO   (ADATA_XO   )
    )

endmodule