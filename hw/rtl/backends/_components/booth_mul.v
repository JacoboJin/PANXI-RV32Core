`include "cla_adder.v"
`include "compressor_3to2.v"
`include "compressor_4to2.v"

module booth_mul#(
	parameter NUM = 16,
	parameter BASE = 8
)(
	input [NUM-1:0] a,
	input [NUM-1:0] b,
	input sign,
	output [NUM*2-1:0] out
    );


localparam BOOTH_IN = $clog2(BASE);	
localparam BOOTH_NUM = NUM / BOOTH_IN + 1;
localparam BOOTH_LEN = NUM + BOOTH_IN * 3 - 1;
localparam BOOTN_MOD = NUM % BOOTH_IN;

reg [BOOTH_LEN-1:0] booth_data [BOOTH_NUM-1:0];

wire [NUM+1:0] a_3;
wire [BOOTH_NUM-1:0] booth_sign;
wire [BOOTH_NUM*BOOTH_IN-1:0] mid_b;
wire [BOOTH_LEN-1:0] booth_res [BOOTH_NUM:0];
wire [NUM*2-1:0] fin_data;

assign mid_b = {{BOOTH_NUM*BOOTH_IN-NUM{sign & b[NUM-1]}}, b};
assign out = fin_data;

generate								//generate 3a
	if (BASE == 8) begin
		cla_adder #(
			.NUM(NUM+2),
			.ST("hybird")
		) adder (
			.a({{2{sign & a[NUM-1]}}, a}),
			.b({a[NUM-1] & sign, a, 1'b0}),
			.s(a_3)
		);
	end
	else begin
		assign a_3 = 0;
	end
endgenerate								//generate_3a

generate								//generate first booth
	if (BASE == 8) begin
		assign booth_sign[0] = ~sign & mid_b[BOOTH_IN-1] | mid_b[BOOTH_IN-1] & ~a[NUM-1] | sign & ~mid_b[BOOTH_IN-1] & a[NUM-1];
		always @(*) begin
			case ({mid_b[0 +: BOOTH_IN], 1'b0})
				4'h0: begin
					booth_data[0] = {1'b1, {NUM+BOOTH_IN+2{1'b0}}};
				end             
				4'h2: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, {2{sign & a[NUM-1]}}, a};
				end             
				4'h4: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, sign & a[NUM-1], a, 1'b0};
				end             
				4'h6: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, a_3};
				end             
				4'h8: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, ~a, 2'h3};
				end             
				4'ha: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, ~a_3};
				end             
				4'hc: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, ~(sign & a[NUM-1]), ~a, 1'b1};
				end             
				4'he: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, {2{~(sign & a[NUM-1])}}, ~a};
				end             
				default: begin  
					booth_data[0] = {BOOTH_LEN{1'b0}};
				end
			endcase
		end
	end
	else begin
		assign booth_sign[0] = ~sign & mid_b[BOOTH_IN-1] | mid_b[BOOTH_IN-1] & ~a[NUM-1] | sign & ~mid_b[BOOTH_IN-1] & a[NUM-1];
		always @(*) begin
			case ({mid_b[0 +: BOOTH_IN], 1'b0})
				3'h0: begin
					booth_data[0] = {1'b1, {NUM+BOOTH_IN+1{1'b0}}};
				end             
				3'h2: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, sign & a[NUM-1], a};
				end             
				3'h4: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, ~a, 1'b1};
				end             
				3'h6: begin     
					booth_data[0] = {~booth_sign[0], {BOOTH_IN{booth_sign[0]}}, ~(sign & a[NUM-1]), ~a};
				end             
				default: begin  
					booth_data[0] = {BOOTH_LEN{1'b0}};
				end
			endcase
		end
	end
endgenerate								//generate_first_booth

genvar i;
generate								//booth encode
	for (i = 1; i < BOOTH_NUM; i = i + 1) begin
		if (BASE == 8) begin
			assign booth_sign[i] = ~sign & mid_b[BOOTH_IN*(i+1)-1] | mid_b[BOOTH_IN*(i+1)-1] & ~a[NUM-1] | sign & ~mid_b[BOOTH_IN*(i+1)-1] & a[NUM-1];
			always @(*) begin
				case (mid_b[BOOTH_IN*i-1 +: (BOOTH_IN+1)])
					4'h0: begin
						booth_data[i] = {3'b111, {NUM+2{1'b0}}, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h1: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {2{sign & a[NUM-1]}}, a, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h2: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {2{sign & a[NUM-1]}}, a, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h3: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {1{sign & a[NUM-1]}}, a, 3'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h4: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {1{sign & a[NUM-1]}}, a, 3'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h5: begin
						booth_data[i] = {2'b11, ~booth_sign[i], a_3, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h6: begin
						booth_data[i] = {2'b11, ~booth_sign[i], a_3, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h7: begin
						booth_data[i] = {2'b11, ~booth_sign[i], a, 4'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h8: begin
						booth_data[i] = {2'b11, ~booth_sign[i], ~a, 2'h3, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'h9: begin
						booth_data[i] = {2'b11, ~booth_sign[i], ~a_3, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'ha: begin
						booth_data[i] = {2'b11, ~booth_sign[i], ~a_3, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'hb: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {1{~(sign & a[NUM-1])}}, ~a, 1'b1, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'hc: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {1{~(sign & a[NUM-1])}}, ~a, 1'b1, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'hd: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {2{~(sign & a[NUM-1])}}, ~a, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'he: begin
						booth_data[i] = {2'b11, ~booth_sign[i], {2{~(sign & a[NUM-1])}}, ~a, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					4'hf: begin
						booth_data[i] = {3'b110, {NUM+2{1'b1}}, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					default: begin
						booth_data[i] = {BOOTH_LEN{1'b0}};
					end
				endcase
			end
		end
		else begin
			assign booth_sign[i] = ~sign & mid_b[BOOTH_IN*(i+1)-1] | mid_b[BOOTH_IN*(i+1)-1] & ~a[NUM-1] | sign & ~mid_b[BOOTH_IN*(i+1)-1] & a[NUM-1];
			always @(*) begin
				case (mid_b[BOOTH_IN*i-1 +: (BOOTH_IN+1)])
					3'h0: begin
						booth_data[i] = {2'b11, {NUM+1{1'b0}}, 1'b0, mid_b[BOOTH_IN*i-1]};
					end
					3'h1: begin
						booth_data[i] = {1'b1, ~booth_sign[i], {1{sign & a[NUM-1]}}, a, 1'h0, mid_b[BOOTH_IN*i-1]};
					end
					3'h2: begin
						booth_data[i] = {1'b1, ~booth_sign[i], {1{sign & a[NUM-1]}}, a, 1'h0, mid_b[BOOTH_IN*i-1]};
					end
					3'h3: begin
						booth_data[i] = {1'b1, ~booth_sign[i], a, 2'h0, mid_b[BOOTH_IN*i-1]};
					end
					3'h4: begin
						booth_data[i] = {1'b1, ~booth_sign[i], ~a, 2'h2, mid_b[BOOTH_IN*i-1]};
					end
					3'h5: begin
						booth_data[i] = {1'b1, ~booth_sign[i], {1{~(sign & a[NUM-1])}}, a, 1'h0, mid_b[BOOTH_IN*i-1]};
					end
					3'h6: begin
						booth_data[i] = {1'b1, ~booth_sign[i], {1{~(sign & a[NUM-1])}}, a, 1'h0, mid_b[BOOTH_IN*i-1]};
					end
					3'h7: begin
						booth_data[i] = {2'b10, {NUM+1{1'b1}}, 1'b0, mid_b[BOOTH_IN*i-1]};
					end
					default: begin
						booth_data[i] = {BOOTH_LEN{1'b0}};
					end
				endcase
			end
		end
	end
endgenerate								//booth_encode

genvar j;
generate								//correct encode error
	for (j = 0; j <= BOOTH_NUM; j = j + 1) begin
		if (j == BOOTH_NUM) begin
			assign booth_res[j] = mid_b[BOOTH_IN*BOOTH_NUM-1] << ((BOOTH_NUM-1)*BOOTH_IN);
		end
		else if (j == BOOTH_NUM - 1) begin
			assign booth_res[j] = booth_data[j] & ({{BOOTH_IN-BOOTN_MOD*2-1{1'b0}}, {BOOTH_LEN-(BOOTH_IN*2-BOOTN_MOD-1){1'b1}}});
		end
		else if (j == BOOTH_NUM - 2) begin
			assign booth_res[j] = booth_data[j] & ({{BOOTH_IN-BOOTN_MOD-1{1'b0}}, {BOOTH_LEN-(BOOTH_IN-BOOTN_MOD-1){1'b1}}});
		end
		else begin
			assign booth_res[j] = booth_data[j];
		end
	end
endgenerate								//correct encode error

generate                                //adder tree
	case (BOOTH_NUM+1) 
		32'd3: begin : tree_adder_3 // veritied
			wire [BOOTH_LEN+BOOTH_IN-1:0] cp3_1_1_sum, cp3_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN+1:0] full_data;
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp3_1_1(
				.a({{BOOTH_IN{1'b0}}, booth_res[2]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[0]}),
				.c({booth_res[1]}),
				.sum(cp3_1_1_sum),
				.carry(cp3_1_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN+2),
				.ST("hybird")
			)adder_fin(
				.a({2'b0, cp3_1_1_sum}),
				.b({1'b0, cp3_1_1_carry, 1'b0}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_3		
		32'd4: begin : tree_adder_4 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN+1:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN+2),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_1_1_sum}),
				.b({1'b0, cp4_1_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_4
		32'd5: begin : tree_adder_5 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*2:0] cp3_2_1_sum, cp3_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*2+1:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[4]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2+1)
			)cp3_2_1(
				.a({{BOOTH_IN{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN{1'b0}}, cp4_1_1_carry}),
				.c({1'b0, booth_res[3], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_2_1_sum),
				.carry(cp3_2_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*2+2),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp3_2_1_sum}),
				.b({cp3_2_1_carry, 1'b0}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_5
		32'd6: begin : tree_adder_6 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[5]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3+1)
			)cp4_2_1(
				.a({{BOOTH_IN*2{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*2{1'b0}}, cp4_1_1_carry}),
				.c({{BOOTH_IN+1{1'b0}}, booth_res[3], {BOOTH_IN*2{1'b0}}}),
				.d({1'b0, booth_res[4], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*3+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_2_1_sum}),
				.b({1'b0, cp4_2_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_6
		32'd7: begin : tree_adder_7 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*2-1:0] cp3_1_2_sum, cp3_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*4+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*4+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[6]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2)
			)cp3_1_2(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_1_2_sum),
				.carry(cp3_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*4+1)
			)cp4_2_1(
				.a({{BOOTH_IN*3{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*3{1'b0}}, cp4_1_1_carry}),
				.c({1'b0, cp3_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp3_1_2_carry, {BOOTH_IN*2+1{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*4+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_2_1_sum}),
				.b({1'b0, cp4_2_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_7
		32'd8: begin : tree_adder_8 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*5+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*5+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp4_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp4_1_2_carry, {BOOTH_IN*2{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_2_1_sum}),
				.b({1'b0, cp4_2_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_8
		32'd9: begin : tree_adder_9 // veritied
			wire [BOOTH_LEN-1:0] cp3_1_1_sum, cp3_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*2-1:0] cp3_1_2_sum, cp3_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*2-1:0] cp3_1_3_sum, cp3_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp3_2_1_sum, cp3_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp3_2_2_sum, cp3_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*6+1:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*6+2:0] full_data;
			comp_3to2 #(
				.NUM(BOOTH_LEN)
			)cp3_1_1(
				.a({{BOOTH_IN{1'b0}}, booth_res[8]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[0]}),
				.c({booth_res[1]}),
				.sum(cp3_1_1_sum),
				.carry(cp3_1_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2)
			)cp3_1_2(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[2]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[3], {BOOTH_IN{1'b0}}}),
				.c({booth_res[4], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_1_2_sum),
				.carry(cp3_1_2_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2)
			)cp3_1_3(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[5]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[6], {BOOTH_IN{1'b0}}}),
				.c({booth_res[7], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_1_3_sum),
				.carry(cp3_1_3_carry)
			);	
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3+1)
			)cp3_2_1(
				.a({{BOOTH_IN*3+1{1'b0}}, cp3_1_1_sum}),
				.b({{BOOTH_IN*3{1'b0}}, cp3_1_1_carry, 1'b0}),
				.c({1'b0, cp3_1_2_sum, {BOOTH_IN{1'b0}}}),
				.sum(cp3_2_1_sum),
				.carry(cp3_2_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp3_2_2(
				.a({{BOOTH_IN*3{1'b0}}, cp3_1_2_carry, 1'b0}),
				.b({1'b0, cp3_1_3_sum, {BOOTH_IN*3{1'b0}}}),
				.c({cp3_1_3_carry, {BOOTH_IN*3+1{1'b0}}}),
				.sum(cp3_2_2_sum),
				.carry(cp3_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*6+2)
			)cp4_2_1(
				.a({{BOOTH_IN*3+1{1'b0}}, cp3_2_1_sum}),
				.b({{BOOTH_IN*3{1'b0}}, cp3_2_1_carry, 1'b0}),
				.c({1'b0, cp3_2_2_sum, {BOOTH_IN*1{1'b0}}}),
				.d({cp3_2_2_carry, {BOOTH_IN*1+1{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*6+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_9
		32'd10: begin : tree_adder_10 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp3_2_1_sum, cp3_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*5-1:0] cp3_2_2_sum, cp3_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*7:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*7+1:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[9]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp3_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_2_1_sum),
				.carry(cp3_2_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5)
			)cp3_2_2(
				.a({{BOOTH_IN*2-1{1'b0}}, cp4_1_2_carry}),
				.b({{BOOTH_IN{1'b0}}, booth_res[7], {BOOTH_IN*4{1'b0}}}),
				.c({booth_res[8], {BOOTH_IN*5{1'b0}}}),
				.sum(cp3_2_2_sum),
				.carry(cp3_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*7+1)
			)cp4_3_1(
				.a({{BOOTH_IN*2{1'b0}}, cp3_2_1_sum}),
				.b({{BOOTH_IN*2-1{1'b0}}, cp3_2_1_carry, 1'b0}),
				.c({1'b0, cp3_2_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp3_2_2_carry, {BOOTH_IN*2+1{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*7+2),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_10
		32'd11: begin : tree_adder_11 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*2-1:0] cp3_1_3_sum, cp3_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp3_2_1_sum, cp3_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*6:0] cp3_2_2_sum, cp3_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*8+1:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*8+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[10]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2)
			)cp3_1_3(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*1{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_1_3_sum),
				.carry(cp3_1_3_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp3_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_2_1_sum),
				.carry(cp3_2_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*6+1)
			)cp3_2_2(
				.a({{BOOTH_IN*3{1'b0}}, cp4_1_2_carry}),
				.b({1'b0, cp3_1_3_sum, {BOOTH_IN*4{1'b0}}}),
				.c({cp3_1_3_carry, {BOOTH_IN*4+1{1'b0}}}),
				.sum(cp3_2_2_sum),
				.carry(cp3_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*8+2)
			)cp4_3_1(
				.a({{BOOTH_IN*3+1{1'b0}}, cp3_2_1_sum}),
				.b({{BOOTH_IN*3{1'b0}}, cp3_2_1_carry, 1'b0}),
				.c({1'b0, cp3_2_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp3_2_2_carry, {BOOTH_IN*2+1{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*8+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_11
		32'd12: begin : tree_adder_12 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_3_sum, cp4_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp3_2_1_sum, cp3_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*6:0] cp3_2_2_sum, cp3_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*9+1:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*9+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[11]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_3(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[10], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_3_sum),
				.carry(cp4_1_3_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp3_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_2_1_sum),
				.carry(cp3_2_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*6+1)
			)cp3_2_2(
				.a({{BOOTH_IN*3{1'b0}}, cp4_1_2_carry}),
				.b({cp4_1_3_sum, {BOOTH_IN*4{1'b0}}}),
				.c({cp4_1_3_carry, {BOOTH_IN*4{1'b0}}}),
				.sum(cp3_2_2_sum),
				.carry(cp3_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*9+2)
			)cp4_3_1(
				.a({{BOOTH_IN*4+1{1'b0}}, cp3_2_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp3_2_1_carry, 1'b0}),
				.c({1'b0, cp3_2_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp3_2_2_carry, {BOOTH_IN*2+1{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*9+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_12
		32'd13: begin : tree_adder_13 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_3_sum, cp4_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*4-1:0] cp3_2_2_sum, cp3_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*10:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*10+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[12]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_3(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[10], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_3_sum),
				.carry(cp4_1_3_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp4_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp4_1_2_carry, {BOOTH_IN*2{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*4)
			)cp3_2_2(
				.a({{BOOTH_IN-1{1'b0}}, cp4_1_3_sum}),
				.b({{BOOTH_IN-1{1'b0}}, cp4_1_3_carry}),
				.c({booth_res[11], {BOOTH_IN*4{1'b0}}}),
				.sum(cp3_2_2_sum),
				.carry(cp3_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*10+1)
			)cp4_3_1(
				.a({{BOOTH_IN*5-1{1'b0}}, cp4_2_1_sum}),
				.b({{BOOTH_IN*5-1{1'b0}}, cp4_2_1_carry}),
				.c({1'b0, cp3_2_2_sum, {BOOTH_IN*6{1'b0}}}),
				.d({cp3_2_2_carry, {BOOTH_IN*6+1{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*10+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_13
		32'd14: begin : tree_adder_14 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_3_sum, cp4_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*5+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*5:0] cp4_2_2_sum, cp4_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*11+1:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*11+2:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[13]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_3(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[10], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_3_sum),
				.carry(cp4_1_3_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp4_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp4_1_2_carry, {BOOTH_IN*2{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5)
			)cp4_2_2(
				.a({{BOOTH_IN*2-1{1'b0}}, cp4_1_3_sum}),
				.b({{BOOTH_IN*2-1{1'b0}}, cp4_1_3_carry}),
				.c({{BOOTH_IN{1'b0}}, booth_res[11], {BOOTH_IN*4{1'b0}}}),
				.d({booth_res[12], {BOOTH_IN*5{1'b0}}}),
				.sum(cp4_2_2_sum),
				.carry(cp4_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*11+1)
			)cp4_3_1(
				.a({{BOOTH_IN*6{1'b0}}, cp4_2_1_sum}),
				.b({{BOOTH_IN*6{1'b0}}, cp4_2_1_carry}),
				.c({cp4_2_2_sum, {BOOTH_IN*6{1'b0}}}),
				.d({cp4_2_2_carry, {BOOTH_IN*6{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*11+3),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_14
		32'd15: begin : tree_adder_15 // veritied
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_3_sum, cp4_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*2-1:0] cp3_1_4_sum, cp3_1_4_carry;
			wire [BOOTH_LEN+BOOTH_IN*5+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*6+1:0] cp4_2_2_sum, cp4_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*12+2:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*12+3:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[14]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_3(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[10], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_3_sum),
				.carry(cp4_1_3_carry)
			);
			comp_3to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*2)
			)cp3_1_4(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[11]}),
				.b({{BOOTH_IN{1'b0}}, booth_res[12], {BOOTH_IN{1'b0}}}),
				.c({booth_res[13], {BOOTH_IN*2{1'b0}}}),
				.sum(cp3_1_4_sum),
				.carry(cp3_1_4_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp4_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp4_1_2_carry, {BOOTH_IN*2{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*6+1)
			)cp4_2_2(
				.a({{BOOTH_IN*3{1'b0}}, cp4_1_3_sum}),
				.b({{BOOTH_IN*3{1'b0}}, cp4_1_3_carry}),
				.c({1'b0, cp3_1_4_sum, {BOOTH_IN*4{1'b0}}}),
				.d({cp3_1_4_carry, {BOOTH_IN*4+1{1'b0}}}),
				.sum(cp4_2_2_sum),
				.carry(cp4_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*12+2)
			)cp4_3_1(
				.a({{BOOTH_IN*6{1'b0}}, cp4_2_1_sum}),
				.b({{BOOTH_IN*6{1'b0}}, cp4_2_1_carry}),
				.c({cp4_2_2_sum, {BOOTH_IN*6{1'b0}}}),
				.d({cp4_2_2_carry, {BOOTH_IN*6{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*12+4),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_15
		32'd16: begin : tree_adder_16
			wire [BOOTH_LEN+BOOTH_IN:0] cp4_1_1_sum, cp4_1_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_2_sum, cp4_1_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_3_sum, cp4_1_3_carry;
			wire [BOOTH_LEN+BOOTH_IN*3:0] cp4_1_4_sum, cp4_1_4_carry;
			wire [BOOTH_LEN+BOOTH_IN*5+1:0] cp4_2_1_sum, cp4_2_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*7+1:0] cp4_2_2_sum, cp4_2_2_carry;
			wire [BOOTH_LEN+BOOTH_IN*13+2:0] cp4_3_1_sum, cp4_3_1_carry;
			wire [BOOTH_LEN+BOOTH_IN*13+3:0] full_data;
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN)
			)cp4_1_1(
				.a({{BOOTH_IN*2{1'b0}}, booth_res[15]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[0]}),
				.c({{BOOTH_IN{1'b0}}, booth_res[1]}),
				.d({booth_res[2], {BOOTH_IN{1'b0}}}),
				.sum(cp4_1_1_sum),
				.carry(cp4_1_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_2(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[3]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[4], {BOOTH_IN{1'b0}}}),
				.c({{BOOTH_IN{1'b0}}, booth_res[5], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[6], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_2_sum),
				.carry(cp4_1_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_3(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[7]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[8], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[9], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[10], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_3_sum),
				.carry(cp4_1_3_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*3)
			)cp4_1_4(
				.a({{BOOTH_IN*3{1'b0}}, booth_res[11]}),
				.b({{BOOTH_IN*2{1'b0}}, booth_res[12], {BOOTH_IN*1{1'b0}}}),
				.c({{BOOTH_IN*1{1'b0}}, booth_res[13], {BOOTH_IN*2{1'b0}}}),
				.d({booth_res[14], {BOOTH_IN*3{1'b0}}}),
				.sum(cp4_1_4_sum),
				.carry(cp4_1_4_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*5+1)
			)cp4_2_1(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_1_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_1_carry}),
				.c({cp4_1_2_sum, {BOOTH_IN*2{1'b0}}}),
				.d({cp4_1_2_carry, {BOOTH_IN*2{1'b0}}}),
				.sum(cp4_2_1_sum),
				.carry(cp4_2_1_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*7+1)
			)cp4_2_2(
				.a({{BOOTH_IN*4{1'b0}}, cp4_1_3_sum}),
				.b({{BOOTH_IN*4{1'b0}}, cp4_1_3_carry}),
				.c({cp4_1_4_sum, {BOOTH_IN*4{1'b0}}}),
				.d({cp4_1_4_carry, {BOOTH_IN*4{1'b0}}}),
				.sum(cp4_2_2_sum),
				.carry(cp4_2_2_carry)
			);
			comp_4to2 #(
				.NUM(BOOTH_LEN+BOOTH_IN*13+2)
			)cp4_3_1(
				.a({{BOOTH_IN*7{1'b0}}, cp4_2_1_sum}),
				.b({{BOOTH_IN*7{1'b0}}, cp4_2_1_carry}),
				.c({cp4_2_2_sum, {BOOTH_IN*6{1'b0}}}),
				.d({cp4_2_2_carry, {BOOTH_IN*6{1'b0}}}),
				.sum(cp4_3_1_sum),
				.carry(cp4_3_1_carry)
			);
			cla_adder #(
				.NUM(BOOTH_LEN+BOOTH_IN*13+4),
				.ST("hybird")
			)adder_fin(
				.a({1'b0, cp4_3_1_sum}),
				.b({1'b0, cp4_3_1_carry}),
				.s(full_data)
			);
			assign fin_data = full_data;
		end : tree_adder_16		
	endcase
endgenerate                             //adder tree

endmodule