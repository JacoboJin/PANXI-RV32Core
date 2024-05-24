// panxi_soc dff with enable signal (async, high reset)
module panxi_dffers #(
    parameter WIDTH = 8
)(
    input  logic                clk  , 
    input  logic                rstn , 
    input  logic                en   ,
    input  logic [WIDTH-1:0]    d    ,
    output logic [WIDTH-1:0]    q
);
    logic [WIDTH-1:0] d_r;

    always_ff @(posedge clk or negedge rstn) begin
        if (rstn) begin
            d_r <= {WIDTH{1'b0}};
        end
        else if(en) begin
            d_r <= d;
        end
    end

    assign q = d_r;

    `ifndef FPGA_SOURCE
    `ifndef SYNTHESIS
        panxi_xchecker #(
            .WIDTH(1)
        )u_panxi_xchecker(
            .dat    (en     ),
            .clk    (clk    )
        );
    `endif
    `endif
endmodule


// panxi_soc dff with enable signal (async, low reset)
module panxi_dffer #(
    parameter WIDTH = 8
)(
    input  logic                clk  , 
    input  logic                rstn , 
    input  logic                en   ,
    input  logic [WIDTH-1:0]    d    ,
    output logic [WIDTH-1:0]    q
);
    logic [WIDTH-1:0] d_r;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            d_r <= {WIDTH{1'b0}};
        end
        else if(en) begin
            d_r <= d;
        end
    end

    assign q = d_r;

    `ifndef FPGA_SOURCE
    `ifndef SYNTHESIS
        panxi_xchecker #(
            .WIDTH(1)
        )u_panxi_xchecker(
            .dat    (en     ),
            .clk    (clk    )
        );
    `endif
    `endif
endmodule


// panxi_soc dff with enable signal (no reset)
module panxi_dffe #(
    parameter WIDTH = 8
)(
    input  logic                clk  , 
    input  logic                en   ,
    input  logic [WIDTH-1:0]    d    ,
    output logic [WIDTH-1:0]    q
);
    logic [WIDTH-1:0] d_r;

    always_ff @(posedge clk) begin
        if(en) begin
            d_r <= d;
        end
    end

    assign q = d_r;

    `ifndef FPGA_SOURCE
    `ifndef SYNTHESIS
        panxi_xchecker #(
            .WIDTH(1)
        )u_panxi_xchecker(
            .dat    (en     ),
            .clk    (clk    )
        );
    `endif
    `endif
endmodule


// panxi_soc dff (async, high reset)
module panxi_dffrs #(
    parameter WIDTH = 8
)(
    input  logic                clk  , 
    input  logic                rstn ,
    input  logic [WIDTH-1:0]    d    ,
    output logic [WIDTH-1:0]    q
);
    logic [WIDTH-1:0] d_r;

    always_ff @(posedge clk or negedge rstn) begin
        if (rstn) begin
            d_r <= {WIDTH{1'b0}};
        end
        else begin
            d_r <= d;
        end
    end

    assign q = d_r;

    `ifndef FPGA_SOURCE
    `ifndef SYNTHESIS
        panxi_xchecker #(
            .WIDTH(1)
        )u_panxi_xchecker(
            .dat    (en     ),
            .clk    (clk    )
        );
    `endif
    `endif
endmodule


// panxi_soc dff (async, low reset)
module panxi_dffr #(
    parameter WIDTH = 8
)(
    input  logic                clk  , 
    input  logic                rstn ,
    input  logic [WIDTH-1:0]    d    ,
    output logic [WIDTH-1:0]    q
);
    logic [WIDTH-1:0] d_r;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            d_r <= {WIDTH{1'b0}};
        end
        else begin
            d_r <= d;
        end
    end

    assign q = d_r;

    `ifndef FPGA_SOURCE
    `ifndef SYNTHESIS
        panxi_xchecker #(
            .WIDTH(1)
        )u_panxi_xchecker(
            .dat    (en     ),
            .clk    (clk    )
        );
    `endif
    `endif
endmodule