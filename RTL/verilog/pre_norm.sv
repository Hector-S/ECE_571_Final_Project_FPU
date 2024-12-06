/* pre_norm.sv
** Conversion of Verilog code into SystemVerilog
** ECE 571 Group 17 Project
** 
** Converting Verilog from Rudolf Usselmann (rudi@asics.ws)
*/

`timescale 1ns / 100ps


module pre_norm (
	input logic 		clk,
	input logic  [1:0]	rmode,
	input logic 		add,
	input logic  [31:0]	opa, opb,
	input logic 		opa_nan, opb_nan,
	output logic [26:0]	fracta_out, fractb_out,
	output logic [7:0]	exp_dn_out,
	output logic 		sign,			// sign output
	output logic 		nan_sign, result_zero_sign,
	output logic 		fasu_op			// // operation (add/sub) output
);


////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//

wire logic 		signa, signb;		// alias to opX sign
wire logic 	[7:0]	expa, expb;			// alias to opX exponent
wire logic 	[22:0]	fracta, fractb;		// alias to opX fraction
wire logic 		expa_lt_expb;		// expa is larger than expb indicator
wire logic 		fractb_lt_fracta;	// fractb is larger than fracta indicator
wire logic 	[7:0]	exp_small, exp_large;
wire logic 	[7:0]	exp_diff;		// Numeric difference of the two exponents
wire logic 	[22:0]	adj_op;			// Fraction adjustment: input
wire logic 	[26:0]	adj_op_tmp;
wire logic 	[26:0]	adj_op_out;		// Fraction adjustment: output
wire logic 	[26:0]	fracta_n, fractb_n;	// Fraction selection after normalizing
wire logic 	[26:0]	fracta_s, fractb_s;	// Fraction Sorting out
logic 			sign_d;			// Sign Output
logic 			add_d;			// operation (add/sub)		
wire logic 		expa_dn, expb_dn;
logic 			sticky;
logic 			add_r, signa_r, signb_r;
wire logic 	[4:0]	exp_diff_sft;
wire logic 		exp_lt_27;
wire logic 		op_dn;
wire logic 	[26:0]	adj_op_out_sft;
logic 			fracta_lt_fractb, fracta_eq_fractb;
wire logic 		nan_sign1;

////////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign  signa = opa[31];
assign  signb = opb[31];
assign   expa = opa[30:23];
assign   expb = opb[30:23];
assign fracta = opa[22:0];
assign fractb = opb[22:0];

////////////////////////////////////////////////////////////////////////
//
// Pre-Normalize exponents (and fractions)
//

assign expa_lt_expb = expa > expb;		// expa is larger than expb

// ---------------------------------------------------------------------
// Normalize

assign expa_dn = !(|expa);			// opa denormalized
assign expb_dn = !(|expb);			// opb denormalized

// ---------------------------------------------------------------------
// Calculate the difference between the smaller and larger exponent

wire logic [7:0]	exp_diff1, exp_diff1a, exp_diff2;

assign exp_small  = expa_lt_expb ? expb : expa;
assign exp_large  = expa_lt_expb ? expa : expb;
assign exp_diff1  = exp_large - exp_small;
assign exp_diff1a = exp_diff1-1;
assign exp_diff2  = (expa_dn | expb_dn) ? exp_diff1a : exp_diff1;
assign  exp_diff  = (expa_dn & expb_dn) ? 8'h0 : exp_diff2;

always_ff @(posedge clk) begin	// If numbers are equal we should return zero
	exp_dn_out <= #1 (!add_d & expa==expb & fracta==fractb) ? 8'h0 : exp_large;
end

// ---------------------------------------------------------------------
// Adjust the smaller fraction


assign op_dn	  = expa_lt_expb ? expb_dn : expa_dn;
assign adj_op     = expa_lt_expb ? fractb : fracta;
assign adj_op_tmp = { ~op_dn, adj_op, 3'b0 };	// recover hidden bit (op_dn) 

// adj_op_out is 27 bits wide, so can only be shifted 27 bits to the right
assign exp_lt_27	= exp_diff  > 8'd27;
assign exp_diff_sft	= exp_lt_27 ? 5'd27 : exp_diff[4:0];
assign adj_op_out_sft	= adj_op_tmp >> exp_diff_sft;
assign adj_op_out	= {adj_op_out_sft[26:1], adj_op_out_sft[0] | sticky };

// ---------------------------------------------------------------------
// Get truncated portion (sticky bit)

always_comb begin
   case(exp_diff_sft)		// synopsys full_case parallel_case
	00: sticky = 1'h0;
	01: sticky =  adj_op_tmp[0]; 
	02: sticky = |adj_op_tmp[01:0];
	03: sticky = |adj_op_tmp[02:0];
	04: sticky = |adj_op_tmp[03:0];
	05: sticky = |adj_op_tmp[04:0];
	06: sticky = |adj_op_tmp[05:0];
	07: sticky = |adj_op_tmp[06:0];
	08: sticky = |adj_op_tmp[07:0];
	09: sticky = |adj_op_tmp[08:0];
	10: sticky = |adj_op_tmp[09:0];
	11: sticky = |adj_op_tmp[10:0];
	12: sticky = |adj_op_tmp[11:0];
	13: sticky = |adj_op_tmp[12:0];
	14: sticky = |adj_op_tmp[13:0];
	15: sticky = |adj_op_tmp[14:0];
	16: sticky = |adj_op_tmp[15:0];
	17: sticky = |adj_op_tmp[16:0];
	18: sticky = |adj_op_tmp[17:0];
	19: sticky = |adj_op_tmp[18:0];
	20: sticky = |adj_op_tmp[19:0];
	21: sticky = |adj_op_tmp[20:0];
	22: sticky = |adj_op_tmp[21:0];
	23: sticky = |adj_op_tmp[22:0];
	24: sticky = |adj_op_tmp[23:0];
	25: sticky = |adj_op_tmp[24:0];
	26: sticky = |adj_op_tmp[25:0];
	27: sticky = |adj_op_tmp[26:0];
	default: sticky = 1'hx;
   endcase
end
// ---------------------------------------------------------------------
// Select operands for add/sub (recover hidden bit)

assign fracta_n = expa_lt_expb ? {~expa_dn, fracta, 3'b0} : adj_op_out;
assign fractb_n = expa_lt_expb ? adj_op_out : {~expb_dn, fractb, 3'b0};

// ---------------------------------------------------------------------
// Sort operands (for sub only)

assign fractb_lt_fracta = fractb_n > fracta_n;	// fractb is larger than fracta
assign fracta_s = fractb_lt_fracta ? fractb_n : fracta_n;
assign fractb_s = fractb_lt_fracta ? fracta_n : fractb_n;

always_ff @(posedge clk) begin
	fracta_out <= #1 fracta_s;
	fractb_out <= #1 fractb_s;
end
	
// ---------------------------------------------------------------------
// Determine sign for the output

// sign: 0=Positive Number; 1=Negative Number
always_comb begin
   case({signa, signb, add})		// synopsys full_case parallel_case
   	// Add
	3'b0_0_1: sign_d = 0;
	3'b0_1_1: sign_d = fractb_lt_fracta;
	3'b1_0_1: sign_d = !fractb_lt_fracta;
	3'b1_1_1: sign_d = 1;
	// Sub
	3'b0_0_0: sign_d = fractb_lt_fracta;
	3'b0_1_0: sign_d = 0;
	3'b1_0_0: sign_d = 1;
	3'b1_1_0: sign_d = !fractb_lt_fracta;

	default: sign_d = 1'bx;
   endcase
end

always_ff @(posedge clk) begin
	sign <= #1 sign_d;

	// Fix sign for ZERO result
	signa_r <= #1 signa;
	signb_r <= #1 signb;
	add_r <= #1 add;
	result_zero_sign <= #1	( add_r &  signa_r &  signb_r) 			|
				(!add_r &  signa_r & !signb_r) 			|
				( add_r & (signa_r |  signb_r) & (rmode==3))	|
				(!add_r & (signa_r == signb_r) & (rmode==3));

	// Fix sign for NAN result
	fracta_lt_fractb <= #1 fracta < fractb;
	fracta_eq_fractb <= #1 fracta == fractb;
	nan_sign <= #1 (opa_nan & opb_nan) ? nan_sign1 : opb_nan ? signb_r : signa_r;
end

assign nan_sign1 = fracta_eq_fractb ? (signa_r & signb_r) : fracta_lt_fractb ? signb_r : signa_r;

////////////////////////////////////////////////////////////////////////
//
// Decode Add/Sub operation
//

// add: 1=Add; 0=Subtract
always_comb begin
   case({signa, signb, add})		// synopsys full_case parallel_case
   
   	// Add
	3'b0_0_1: add_d = 1;
	3'b0_1_1: add_d = 0;
	3'b1_0_1: add_d = 0;
	3'b1_1_1: add_d = 1;
	
	// Sub
	3'b0_0_0: add_d = 0;
	3'b0_1_0: add_d = 1;
	3'b1_0_0: add_d = 1;
	3'b1_1_0: add_d = 0;

	default: add_d = 1'bx;
   endcase
end

always_ff @(posedge clk)
	fasu_op <= #1 add_d;

endmodule
