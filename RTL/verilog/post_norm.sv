/* post_norm.sv
** Conversion of Verilog code into SystemVerilog
** ECE 571 Group 17 Project
** 
** Converting Verilog from Rudolf Usselmann (rudi@asics.ws)
*/

`timescale 1ns / 100ps

module post_norm (
	input logic 		clk,					// system clock
	input logic [2:0]	fpu_op,					// Floating point op select
	input logic 		opas,					
	input logic 		sign,					// positive or negative
	input logic [1:0]	rmode,					// rounding mode
	input logic [47:0]	fract_in,
	input logic [1:0]	exp_ovf,				// exponent overflow
	input logic [7:0]	exp_in,
	input logic 		opa_dn, opb_dn,
	input logic 		rem_00,
	input logic [4:0]	div_opa_ldz,
	input logic 		output_zero,
	output wire logic [30:0]out,					// result output
	output logic 		ine,
	output logic 		overflow, underflow,
	output logic 		f2i_out_sign
);

////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//

wire logic 	[22:0]	fract_out;
wire logic 	[7:0]	exp_out;
wire logic 		exp_out1_co;
wire logic 	[22:0]	fract_out_final;
logic 		[22:0]	fract_out_rnd;
wire logic 	[8:0]	exp_next_mi;
wire logic 		dn;
wire logic 		exp_rnd_adj;
wire logic 	[7:0]	exp_out_final;
logic 		[7:0]	exp_out_rnd;
wire logic 		op_dn = opa_dn | opb_dn;
wire logic 		op_mul = fpu_op[2:0]==3'b010;
wire logic 		op_div = fpu_op[2:0]==3'b011;
wire logic 		op_i2f = fpu_op[2:0]==3'b100;
wire logic 		op_f2i = fpu_op[2:0]==3'b101;
logic 		[5:0]	fi_ldz;

wire logic 		g, r, s;
wire logic 		round, round2, round2a, round2_fasu, round2_fmul;
wire logic 	[7:0]	exp_out_rnd0, exp_out_rnd1, exp_out_rnd2, exp_out_rnd2a;
wire logic 	[22:0]	fract_out_rnd0, fract_out_rnd1, fract_out_rnd2, fract_out_rnd2a;
wire logic 		exp_rnd_adj0, exp_rnd_adj2a;
wire logic 		r_sign;
wire logic 		ovf0, ovf1;
wire logic 	[23:0]	fract_out_pl1;
wire logic 	[7:0]	exp_out_pl1, exp_out_mi1;
wire logic 		exp_out_00, exp_out_fe, exp_out_ff, exp_in_00, exp_in_ff;
wire logic 		exp_out_final_ff, fract_out_7fffff;
wire logic 	[24:0]	fract_trunc;
wire logic 	[7:0]	exp_out1;
wire logic 		grs_sel;
wire logic 		fract_out_00, fract_in_00;
wire logic 		shft_co;
wire logic 	[8:0]	exp_in_pl1, exp_in_mi1;
wire logic 	[47:0]	fract_in_shftr;
wire logic 	[47:0]	fract_in_shftl;

wire logic 	[7:0]	exp_div;
wire logic 	[7:0]	shft2;
wire logic 	[7:0]	exp_out1_mi1;
wire logic 		div_dn;
wire logic 		div_nr;
wire logic 		grs_sel_div;

wire logic 		div_inf;
wire logic 	[6:0]	fi_ldz_2a;
wire logic 	[7:0]	fi_ldz_2;
wire logic 	[7:0]	div_shft1, div_shft2, div_shft3, div_shft4;
wire logic 		div_shft1_co;
wire logic 	[8:0]	div_exp1;
wire logic 	[7:0]	div_exp2, div_exp3;
logic 			left_right, lr_mul, lr_div;
wire logic 	[7:0]	shift_right, shftr_mul, shftr_div;
wire logic 	[7:0]	shift_left,  shftl_mul, shftl_div;
wire logic 	[7:0]	fasu_shift;
wire logic 	[7:0]	exp_fix_div;

wire logic 	[7:0]	exp_fix_diva, exp_fix_divb;
wire logic 	[5:0]	fi_ldz_mi1;
wire logic 	[5:0]	fi_ldz_mi22;
wire logic 		exp_zero;
wire logic 	[6:0]	ldz_all;
wire logic 	[7:0]	ldz_dif;

wire logic 	[8:0]	div_scht1a;
wire logic 	[7:0]	f2i_shft;
wire logic 	[55:0]	exp_f2i_1;
wire logic 		f2i_zero, f2i_max;
wire logic 	[7:0]	f2i_emin;
wire logic 	[7:0]	conv_shft;
wire logic 	[7:0]	exp_i2f, exp_f2i, conv_exp;
wire logic 		round2_f2i;

////////////////////////////////////////////////////////////////////////
//
// Normalize and Round Logic
//

// ---------------------------------------------------------------------
// Count Leading zeros in fraction

always_comb begin
   casex(fract_in)	// synopsys full_case parallel_case
	48'b1???????????????????????????????????????????????: fi_ldz =  1;
	48'b01??????????????????????????????????????????????: fi_ldz =  2;
	48'b001?????????????????????????????????????????????: fi_ldz =  3;
	48'b0001????????????????????????????????????????????: fi_ldz =  4;
	48'b00001???????????????????????????????????????????: fi_ldz =  5;
	48'b000001??????????????????????????????????????????: fi_ldz =  6;
	48'b0000001?????????????????????????????????????????: fi_ldz =  7;
	48'b00000001????????????????????????????????????????: fi_ldz =  8;
	48'b000000001???????????????????????????????????????: fi_ldz =  9;
	48'b0000000001??????????????????????????????????????: fi_ldz =  10;
	48'b00000000001?????????????????????????????????????: fi_ldz =  11;
	48'b000000000001????????????????????????????????????: fi_ldz =  12;
	48'b0000000000001???????????????????????????????????: fi_ldz =  13;
	48'b00000000000001??????????????????????????????????: fi_ldz =  14;
	48'b000000000000001?????????????????????????????????: fi_ldz =  15;
	48'b0000000000000001????????????????????????????????: fi_ldz =  16;
	48'b00000000000000001???????????????????????????????: fi_ldz =  17;
	48'b000000000000000001??????????????????????????????: fi_ldz =  18;
	48'b0000000000000000001?????????????????????????????: fi_ldz =  19;
	48'b00000000000000000001????????????????????????????: fi_ldz =  20;
	48'b000000000000000000001???????????????????????????: fi_ldz =  21;
	48'b0000000000000000000001??????????????????????????: fi_ldz =  22;
	48'b00000000000000000000001?????????????????????????: fi_ldz =  23;
	48'b000000000000000000000001????????????????????????: fi_ldz =  24;
	48'b0000000000000000000000001???????????????????????: fi_ldz =  25;
	48'b00000000000000000000000001??????????????????????: fi_ldz =  26;
	48'b000000000000000000000000001?????????????????????: fi_ldz =  27;
	48'b0000000000000000000000000001????????????????????: fi_ldz =  28;
	48'b00000000000000000000000000001???????????????????: fi_ldz =  29;
	48'b000000000000000000000000000001??????????????????: fi_ldz =  30;
	48'b0000000000000000000000000000001?????????????????: fi_ldz =  31;
	48'b00000000000000000000000000000001????????????????: fi_ldz =  32;
	48'b000000000000000000000000000000001???????????????: fi_ldz =  33;
	48'b0000000000000000000000000000000001??????????????: fi_ldz =  34;
	48'b00000000000000000000000000000000001?????????????: fi_ldz =  35;
	48'b000000000000000000000000000000000001????????????: fi_ldz =  36;
	48'b0000000000000000000000000000000000001???????????: fi_ldz =  37;
	48'b00000000000000000000000000000000000001??????????: fi_ldz =  38;
	48'b000000000000000000000000000000000000001?????????: fi_ldz =  39;
	48'b0000000000000000000000000000000000000001????????: fi_ldz =  40;
	48'b00000000000000000000000000000000000000001???????: fi_ldz =  41;
	48'b000000000000000000000000000000000000000001??????: fi_ldz =  42;
	48'b0000000000000000000000000000000000000000001?????: fi_ldz =  43;
	48'b00000000000000000000000000000000000000000001????: fi_ldz =  44;
	48'b000000000000000000000000000000000000000000001???: fi_ldz =  45;
	48'b0000000000000000000000000000000000000000000001??: fi_ldz =  46;
	48'b00000000000000000000000000000000000000000000001?: fi_ldz =  47;
	48'b00000000000000000000000000000000000000000000000?: fi_ldz =  48;
	default: fi_ldz = 0;
   endcase
end

// ---------------------------------------------------------------------
// Normalize

wire logic	exp_in_80;
wire logic	rmode_00, rmode_01, rmode_10, rmode_11;

// Misc common signals
assign exp_in_ff        = &exp_in;
assign exp_in_00        = !(|exp_in);
assign exp_in_80	= exp_in[7] & !(|exp_in[6:0]);
assign exp_out_ff       = &exp_out;
assign exp_out_00       = !(|exp_out);
assign exp_out_fe       = &exp_out[7:1] & !exp_out[0];
assign exp_out_final_ff = &exp_out_final;

assign fract_out_7fffff = &fract_out;
assign fract_out_00     = !(|fract_out);
assign fract_in_00      = !(|fract_in);

assign rmode_00 = (rmode==2'b00);
assign rmode_01 = (rmode==2'b01);
assign rmode_10 = (rmode==2'b10);
assign rmode_11 = (rmode==2'b11);

// Fasu Output will be denormalized ...
assign dn = !op_mul & !op_div & (exp_in_00 | (exp_next_mi[8] & !fract_in[47]) );

// ---------------------------------------------------------------------
// Fraction Normalization
parameter	f2i_emax = 8'h9d;

// Incremented fraction for rounding
assign fract_out_pl1 = fract_out + 1;

// Special Signals for f2i
assign f2i_emin = rmode_00 ? 8'h7e : 8'h7f;
assign f2i_zero = (!opas & (exp_in<f2i_emin)) | (opas & (exp_in>f2i_emax)) | (opas & (exp_in<f2i_emin) & (fract_in_00 | !rmode_11));
assign f2i_max = (!opas & (exp_in>f2i_emax)) | (opas & (exp_in<f2i_emin) & !fract_in_00 & rmode_11);

// Claculate various shifting options

assign {shft_co,shftr_mul} = (!exp_ovf[1] & exp_in_00) ? {1'b0, exp_out} : exp_in_mi1 ;
assign {div_shft1_co, div_shft1} = exp_in_00 ? {1'b0, div_opa_ldz} : div_scht1a;

assign div_scht1a = exp_in-div_opa_ldz; // 9 bits - includes carry out
assign div_shft2  = exp_in+2;
assign div_shft3  = div_opa_ldz+exp_in;
assign div_shft4  = div_opa_ldz-exp_in;

assign div_dn    = op_dn & div_shft1_co;
assign div_nr    = op_dn & exp_ovf[1]  & !(|fract_in[46:23]) & (div_shft3>8'h16);

assign f2i_shft  = exp_in-8'h7d;


always_comb begin : sel_shift_direction
	// Select shifting direction
	priority case(1'b1)
		(op_dn & !exp_ovf[1] & exp_ovf[0]) 	: lr_div = 1;
		(op_dn & exp_ovf[1]) 			: lr_div = 0;
		(op_dn & div_shft1_co) 			: lr_div = 0;
		(op_dn & exp_out_00) 			: lr_div = 1;
		(!op_dn & exp_out_00 & !exp_ovf[1]) 	: lr_div = 1;
		exp_ovf[1]				: lr_div = 0;
		default	: lr_div = 1;
	endcase

	priority case(1'b1)
		(shft_co | (!exp_ovf[1] & exp_in_00) | 
		(!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00) )) : lr_mul = 1;
		(exp_ovf[1] | exp_in_00) 				: lr_mul = 0;
		default							: lr_mul = 1;
	endcase

	priority case(1'b1)
		op_div : left_right = lr_div;
		op_mul : left_right = lr_mul;
		default: left_right = 1;
	endcase
end : sel_shift_direction

// Select Left and Right shift value
assign fasu_shift  = (dn | exp_out_00) ? (exp_in_00 ? 8'h2 : exp_in_pl1[7:0]) : {2'h0, fi_ldz};
assign shift_right = op_div ? shftr_div : shftr_mul;

assign conv_shft = op_f2i ? f2i_shft : {2'h0, fi_ldz};

assign shift_left  = op_div ? shftl_div : 
		     op_mul ? shftl_mul : 
		     (op_f2i | op_i2f) ? conv_shft : fasu_shift;

assign shftl_mul = (shft_co | (!exp_ovf[1] & exp_in_00) | (!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00))) ? exp_in_pl1[7:0] : {2'h0, fi_ldz};

assign shftl_div = ( op_dn & exp_out_00 & !(!exp_ovf[1] & exp_ovf[0])) ? div_shft1[7:0] : 
		(!op_dn & exp_out_00 & !exp_ovf[1]) ? exp_in[7:0] : {2'h0, fi_ldz};

assign shftr_div = (op_dn & exp_ovf[1]) ? div_shft3 : 
		(op_dn & div_shft1_co) 	? div_shft4 : div_shft2;
					
// Do the actual shifting
assign fract_in_shftr   = (|shift_right[7:6])                      ? 0 : fract_in>>shift_right[5:0];
assign fract_in_shftl   = (|shift_left[7:6] | (f2i_zero & op_f2i)) ? 0 : fract_in<<shift_left[5:0];

// Chose final fraction output
assign {fract_out,fract_trunc} = left_right ? fract_in_shftl : fract_in_shftr;

// ---------------------------------------------------------------------
// Exponent Normalization

assign fi_ldz_mi1    = fi_ldz - 1;
assign fi_ldz_mi22   = fi_ldz - 22;
assign exp_out_pl1   = exp_out + 1;
assign exp_out_mi1   = exp_out - 1;
assign exp_in_pl1    = exp_in  + 1;	// 9 bits - includes carry out
assign exp_in_mi1    = exp_in  - 1;	// 9 bits - includes carry out
assign exp_out1_mi1  = exp_out1 - 1;

assign exp_next_mi  = exp_in_pl1 - fi_ldz_mi1;	// 9 bits - includes carry out

assign exp_fix_diva = exp_in - fi_ldz_mi22;
assign exp_fix_divb = exp_in - fi_ldz_mi1;

assign exp_zero  = (exp_ovf[1] & !exp_ovf[0] & op_mul & (!exp_rnd_adj2a | !rmode[1])) | (op_mul & exp_out1_co);
assign {exp_out1_co, exp_out1} = fract_in[47] ? exp_in_pl1 : exp_next_mi;

assign f2i_out_sign =  !opas ? ((exp_in<f2i_emin) ? 0 : (exp_in>f2i_emax) ? 0 : opas) :
			       ((exp_in<f2i_emin) ? 0 : (exp_in>f2i_emax) ? 1 : opas);

assign exp_i2f   = fract_in_00 ? (opas ? 8'h9e : 0) : (8'h9e-fi_ldz);
assign exp_f2i_1 = {{8{fract_in[47]}}, fract_in }<<f2i_shft;
assign exp_f2i   = f2i_zero ? 0 : f2i_max ? 8'hff : exp_f2i_1[55:48];
assign conv_exp  = op_f2i ? exp_f2i : exp_i2f;

assign exp_out = op_div ? exp_div : (op_f2i | op_i2f) ? conv_exp : exp_zero ? 8'h0 : dn ? {6'h0, fract_in[47:46]} : exp_out1;

assign ldz_all   = div_opa_ldz + fi_ldz;
assign ldz_dif   = fi_ldz_2 - div_opa_ldz;
assign fi_ldz_2a = 6'd23 - fi_ldz;
assign fi_ldz_2  = {fi_ldz_2a[6], fi_ldz_2a[6:0]};

assign div_exp1  = exp_in_mi1 + fi_ldz_2;	// 9 bits - includes carry out

assign div_exp2  = exp_in_pl1 - ldz_all;
assign div_exp3  = exp_in + ldz_dif;

assign exp_div =(opa_dn & opb_dn) ? div_exp3 : 
				(opb_dn) ? div_exp1[7:0] :
				(opa_dn & !( (exp_in<div_opa_ldz) | (div_exp2>9'hfe) ))	? div_exp2 :
				(opa_dn | (exp_in_00 & !exp_ovf[1]) ) ? 0 : exp_out1_mi1;

assign div_inf = opb_dn & !opa_dn & (div_exp1[7:0] < 8'h7f);

// ---------------------------------------------------------------------
// Round

// Extract rounding (GRS) bits
assign grs_sel_div = op_div & (exp_ovf[1] | div_dn | exp_out1_co | exp_out_00);

assign g = grs_sel_div ? fract_out[0]                   : fract_out[0];
assign r = grs_sel_div ? (fract_trunc[24] & !div_nr)    : fract_trunc[24];
assign s = grs_sel_div ? |fract_trunc[24:0]             : (|fract_trunc[23:0] | (fract_trunc[24] & op_div));

// Round to nearest even
assign round = (g & r) | (r & s) ;
assign {exp_rnd_adj0, fract_out_rnd0} = round ? fract_out_pl1 : {1'b0, fract_out};
assign exp_out_rnd0 =  exp_rnd_adj0 ? exp_out_pl1 : exp_out;
assign ovf0 = exp_out_final_ff & !rmode_01 & !op_f2i;

// round to zero
assign fract_out_rnd1 = (exp_out_ff & !op_div & !dn & !op_f2i) ? 23'h7fffff : fract_out;
assign exp_fix_div    = (fi_ldz>22) ? exp_fix_diva : exp_fix_divb;
assign exp_out_rnd1   = (g & r & s & exp_in_ff) ? (op_div ? exp_fix_div : exp_next_mi[7:0]) :
						(exp_out_ff & !op_f2i) ? exp_in : exp_out;
assign ovf1 = exp_out_ff & !dn;

// round to +inf (UP) and -inf (DOWN)
assign r_sign = sign;

assign round2a = !exp_out_fe | !fract_out_7fffff | (exp_out_fe & fract_out_7fffff);
assign round2_fasu = ((r | s) & !r_sign) & (!exp_out[7] | (exp_out[7] & round2a));

assign round2_fmul = !r_sign & 
		((exp_ovf[1] & !fract_in_00 &	
		( ((!exp_out1_co | op_dn) & (r | s | (!rem_00 & op_div) )) | fract_out_00 | (!op_dn & !op_div))) |
		((r | s | (!rem_00 & op_div)) & 
		((!exp_ovf[1] & (exp_in_80 | !exp_ovf[0])) | op_div | ( exp_ovf[1] & !exp_ovf[0] & exp_out1_co))));

assign round2_f2i = rmode_10 & (( |fract_in[23:0] & !opas & (exp_in<8'h80 )) | (|fract_trunc));
assign round2 = (op_mul | op_div) ? round2_fmul : op_f2i ? round2_f2i : round2_fasu;

assign {exp_rnd_adj2a, fract_out_rnd2a} = round2 ? fract_out_pl1 : {1'b0, fract_out};
assign exp_out_rnd2a  = exp_rnd_adj2a ? ((exp_ovf[1] & op_mul) ? exp_out_mi1 : exp_out_pl1) : exp_out;

assign fract_out_rnd2 = (r_sign & exp_out_ff & !op_div & !dn & !op_f2i) ? 23'h7fffff : fract_out_rnd2a;
assign exp_out_rnd2   = (r_sign & exp_out_ff & !op_f2i) ? 8'hfe      : exp_out_rnd2a;


// Choose rounding mode
always_comb begin
	case(rmode)	// synopsys full_case parallel_case
	   0: exp_out_rnd = exp_out_rnd0;
	   1: exp_out_rnd = exp_out_rnd1;
	 2,3: exp_out_rnd = exp_out_rnd2;
	endcase
end

always_comb begin
	case(rmode)	// synopsys full_case parallel_case
	   0: fract_out_rnd = fract_out_rnd0;
	   1: fract_out_rnd = fract_out_rnd1;
	 2,3: fract_out_rnd = fract_out_rnd2;
	endcase
end
// ---------------------------------------------------------------------
// Final Output Mux
// Fix Output for denormalized and special numbers
wire	max_num, inf_out;

assign	max_num =   (!rmode_00 & (op_mul | op_div ) & 
					(( exp_ovf[1] &  exp_ovf[0]) |
					(!exp_ovf[1] & !exp_ovf[0] & exp_in_ff & (fi_ldz_2<24) & (exp_out!=8'hfe)))) |
					( op_div & 
					(( rmode_01 & ( div_inf |
					(exp_out_ff & !exp_ovf[1] ) |
					(exp_ovf[1] &  exp_ovf[0] ))) |
					( rmode[1] & !exp_ovf[1] & 
					(( exp_ovf[0] & exp_in_ff & r_sign & fract_in[47]) |
					(  r_sign & 
					((fract_in[47] & div_inf) |
					(exp_in[7] & !exp_out_rnd[7] & !exp_in_80 & exp_out!=8'h7f ) |
					(exp_in[7] &  exp_out_rnd[7] & r_sign & exp_out_ff & op_dn & div_exp1>9'h0fe ))) |
					( exp_in_00 & r_sign & 
					(div_inf | (r_sign & exp_out_ff & fi_ldz_2<24)))))));


assign inf_out = (rmode[1] & (op_mul | op_div) & !r_sign & ((exp_in_ff & !op_div) |
				 (exp_ovf[1] & exp_ovf[0] & (exp_in_00 | exp_in[7])))) | 
				 (div_inf & op_div & 
				 (rmode_00 | 
				 (rmode[1] & !exp_in_ff & !exp_ovf[1] & !exp_ovf[0] & !r_sign ) |
				 (rmode[1] & !exp_ovf[1] & exp_ovf[0] & exp_in_00 & !r_sign))) | 
				 (op_div & rmode[1] & exp_in_ff & op_dn & !r_sign & (fi_ldz_2 < 24) & (exp_out_rnd!=8'hfe));

assign fract_out_final =	(inf_out | ovf0 | output_zero ) ? 23'h0 :
				(max_num | (f2i_max & op_f2i) ) ? 23'h7fffff :
				fract_out_rnd;

assign exp_out_final =	((op_div & exp_ovf[1] & !exp_ovf[0]) | output_zero ) ? 8'h00 :
			((op_div & exp_ovf[1] &  exp_ovf[0] & rmode_00) | inf_out | (f2i_max & op_f2i) ) ? 8'hff :
			max_num ? 8'hfe :
			exp_out_rnd;


// ---------------------------------------------------------------------
// Pack Result

assign out = {exp_out_final, fract_out_final};

// ---------------------------------------------------------------------
// Exceptions
wire logic underflow_fmul;
wire logic overflow_fdiv;
wire logic undeflow_div;

wire logic z =	shft_co | ( exp_ovf[1] |  exp_in_00) |
			(!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00));

assign underflow_fmul = ( (|fract_trunc) & z & !exp_in_ff ) |
			(fract_out_00 & !fract_in_00 & exp_ovf[1]);

assign undeflow_div = !(exp_ovf[1] &  exp_ovf[0] & rmode_00) & !inf_out & !max_num & exp_out_final!=8'hff & 
						(((|fract_trunc) & !opb_dn 			& 
						(( op_dn & !exp_ovf[1] & exp_ovf[0])|
						( op_dn &  exp_ovf[1])				|
						( op_dn &  div_shft1_co)			| 
						  exp_out_00					|
						  exp_ovf[1])) 					|

						( exp_ovf[1] & !exp_ovf[0] 			& 
						((  op_dn & exp_in>8'h16 & fi_ldz<23) 		|
						(  op_dn & exp_in<23 & fi_ldz<23 & !rem_00)	|
						( !op_dn & (exp_in[7]==exp_div[7]) & !rem_00) 	|
						( !op_dn & exp_in_00 & (exp_div[7:1]==7'h7f) ) 	|
						( !op_dn & exp_in<8'h7f & exp_in>8'h20 ))) 	|

						(!exp_ovf[1] & !exp_ovf[0] 			& 
						(( op_dn & fi_ldz<23 & exp_out_00)  		|
						( exp_in_00 & !rem_00) 				|
						( !op_dn & ldz_all<23 & exp_in==1 & exp_out_00 & !rem_00))));

assign underflow = op_div ? undeflow_div : op_mul ? underflow_fmul : (!fract_in[47] & exp_out1_co) & !dn;

assign overflow_fdiv =	inf_out |
			(!rmode_00 & max_num) |
			(exp_in[7] & op_dn & exp_out_ff) |
			(exp_ovf[0] & (exp_ovf[1] | exp_out_ff) );

assign overflow  = op_div ? overflow_fdiv : (ovf0 | ovf1);

wire logic f2i_ine;

assign f2i_ine =	(f2i_zero & !fract_in_00 & !opas) |
			(|fract_trunc) |
			(f2i_zero & (exp_in<8'h80) & opas & !fract_in_00) |
			(f2i_max & rmode_11 & (exp_in<8'h80));



assign ine =	op_f2i ? f2i_ine :
		op_i2f ? (|fract_trunc) :
		((r & !dn) | (s & !dn) | max_num | (op_div & !rem_00));

// ---------------------------------------------------------------------
// Debugging Stuff

// synopsys translate_off

wire logic 	[26:0]	fracta_del, fractb_del;
wire logic 	[2:0]	grs_del;
wire logic 			dn_del;
wire logic 	[7:0]	exp_in_del;
wire logic 	[7:0]	exp_out_del;
wire logic 	[22:0]	fract_out_del;
wire logic 	[47:0]	fract_in_del;
wire logic 			overflow_del;
wire logic 	[1:0]	exp_ovf_del;
wire logic 	[22:0]	fract_out_x_del, fract_out_rnd2a_del;
wire logic 	[24:0]	trunc_xx_del;
wire logic 			exp_rnd_adj2a_del;
wire logic 	[22:0]	fract_dn_del;
wire logic 	[4:0]	div_opa_ldz_del;
wire logic 	[23:0]	fracta_div_del;
wire logic 	[23:0]	fractb_div_del;
wire logic 			div_inf_del;
wire logic 	[7:0]	fi_ldz_2_del;
wire logic 			inf_out_del, max_out_del;
wire logic 	[5:0]	fi_ldz_del;
wire logic 			rx_del;
wire logic 			ez_del;
wire logic 			lr;
wire logic 	[7:0]	shr, shl, exp_div_del;

delay2 #26 ud000(clk, test.u0.fracta, fracta_del);
delay2 #26 ud001(clk, test.u0.fractb, fractb_del);
delay1  #2 ud002(clk, {g,r,s}, grs_del);
delay1  #0 ud004(clk, dn, dn_del);
delay1  #7 ud005(clk, exp_in, exp_in_del);
delay1  #7 ud007(clk, exp_out_rnd, exp_out_del);
delay1 #47 ud009(clk, fract_in, fract_in_del);
delay1  #0 ud010(clk, overflow, overflow_del);
delay1  #1 ud011(clk, exp_ovf, exp_ovf_del);
delay1 #22 ud014(clk, fract_out, fract_out_x_del);
delay1 #24 ud015(clk, fract_trunc, trunc_xx_del);
delay1 	#0 ud017(clk, exp_rnd_adj2a, exp_rnd_adj2a_del);
delay1  #4 ud019(clk, div_opa_ldz, div_opa_ldz_del);
delay3 #23 ud020(clk, test.u0.fdiv_opa[49:26],	fracta_div_del);
delay3 #23 ud021(clk, test.u0.fractb_mul,	fractb_div_del);
delay1 	#0 ud023(clk, div_inf, div_inf_del);
delay1  #7 ud024(clk, fi_ldz_2, fi_ldz_2_del);
delay1 	#0 ud025(clk, inf_out, inf_out_del);
delay1 	#0 ud026(clk, max_num, max_num_del);
delay1 	#5 ud027(clk, fi_ldz, fi_ldz_del);
delay1  #0 ud028(clk, rem_00, rx_del);

delay1  #0 ud029(clk, left_right, lr);
delay1  #7 ud030(clk, shift_right, shr);
delay1  #7 ud031(clk, shift_left, shl);
delay1 #22 ud032(clk, fract_out_rnd2a, fract_out_rnd2a_del);

delay1  #7 ud033(clk, exp_div, exp_div_del);

always @(test.error_event)
   begin

	$display("\n----------------------------------------------");

	$display("ERROR: GRS: %b exp_ovf: %b dn: %h exp_in: %h exp_out: %h, exp_rnd_adj2a: %b",
			grs_del, exp_ovf_del, dn_del, exp_in_del, exp_out_del, exp_rnd_adj2a_del);

	$display("      div_opa: %b, div_opb: %b, rem_00: %b, exp_div: %h",
			fracta_div_del, fractb_div_del, rx_del, exp_div_del);

	$display("      lr: %b, shl: %h, shr: %h",
			lr, shl, shr);


	$display("       overflow: %b, fract_in=%b  fa:%h fb:%h",
			overflow_del, fract_in_del, fracta_del, fractb_del);

	$display("       div_opa_ldz: %h, div_inf: %b, inf_out: %b, max_num: %b, fi_ldz: %h, fi_ldz_2: %h",
			div_opa_ldz_del, div_inf_del, inf_out_del, max_num_del, fi_ldz_del, fi_ldz_2_del);

	$display("       fract_out_x: %b, fract_out_rnd2a_del: %h, fract_trunc: %b\n",
			fract_out_x_del, fract_out_rnd2a_del, trunc_xx_del);
   end


// synopsys translate_on

endmodule : post_norm

// synopsys translate_off

module delay1(clk, in, out);
parameter	N = 1;
input	[N:0]	in;
output	[N:0]	out;
input		clk;

reg	[N:0]	out;

always_ff @(posedge clk)
	out <= #1 in;

endmodule


module delay2(clk, in, out);
parameter	N = 1;
input	[N:0]	in;
output	[N:0]	out;
input		clk;

reg	[N:0]	out, r1;

always_ff @(posedge clk) begin
	r1 <= #1 in;
	out <= #1 r1;
end 
endmodule

module delay3(clk, in, out);
parameter	N = 1;
input	[N:0]	in;
output	[N:0]	out;
input		clk;

reg	[N:0]	out, r1, r2;

always_ff @(posedge clk) begin
	r1 <= #1 in;
	r2 <= #1 r1;
	out <= #1 r2;
end
endmodule
