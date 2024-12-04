`timescale 1ns / 100ps

module post_norm(
       input logic clk, 
	   input logic [2:0]fpu_op, 
	   input logic opas, 
	   input logic sign, 
	   input logic [1:0] rmode, 
	   input logic [47:0] fract_in, 
	   input logic [1:0] exp_in, 
	   input logic  [1:0] exp_ovf,
	   input logic opa_dn, 
	   input logic opb_dn, 
	   input logic  rem_00, 
	   input logic [4:0] div_opa_ldz, 
	   input logic output_zero, 
	   output logic [30:0] out,
	   output logic ine, 
	   output logic overflow, 
	   output logic underflow, 
	   output logic f2i_out_sign
);

// Local Wires and registers


logic	[22:0]	fract_out;
logic	[7:0]	exp_out;
//logic	[30:0]	out;
logic		    exp_out1_co;
logic	[22:0]	fract_out_final; // changed to wire due to multiple drivers
logic	[22:0]	fract_out_rnd;
logic	[8:0]	exp_next_mi;
logic		    dn;
logic           exp_rnd_adj;
logic   [7:0]	exp_out_final;
logic	[7:0]	exp_out_rnd;
logic		op_dn = opa_dn | opb_dn;
logic		op_mul = fpu_op[2:0]==3'b010; //// check this 
logic		op_div = fpu_op[2:0]==3'b011;
logic		op_i2f = fpu_op[2:0]==3'b100;
logic		op_f2i = fpu_op[2:0]==3'b101;
logic   [5:0]	fi_ldz;

logic		g, r, s;
logic		round, round2, round2a, round2_fasu, round2_fmul;
logic	[7:0]	exp_out_rnd0, exp_out_rnd1, exp_out_rnd2, exp_out_rnd2a;
logic	[22:0]	fract_out_rnd0, fract_out_rnd1, fract_out_rnd2, fract_out_rnd2a;
logic		    exp_rnd_adj0, exp_rnd_adj2a;
logic		    r_sign;
logic		    ovf0, ovf1;
logic	[23:0]	fract_out_pl1;
logic	[7:0]	exp_out_pl1, exp_out_mi1;
logic		    exp_out_00, exp_out_fe, exp_out_ff, exp_in_00, exp_in_ff;
logic		    exp_out_final_ff, fract_out_7fffff;
logic	[24:0]	fract_trunc;
logic	[7:0]	exp_out1;
logic		grs_sel;
logic		fract_out_00, fract_in_00;
logic		shft_co;
logic	[8:0]	exp_in_pl1, exp_in_mi1;
logic	[47:0]	fract_in_shftr;
logic	[47:0]	fract_in_shftl;

logic	[7:0]	exp_div;
logic	[7:0]	shft2;
logic	[7:0]	exp_out1_mi1;
logic		div_dn;
logic		div_nr;
logic		grs_sel_div;

logic		div_inf;
logic	[6:0]	fi_ldz_2a;
logic	[7:0]	fi_ldz_2;
logic	[7:0]	div_shft1, div_shft2, div_shft3, div_shft4;
	
logic		div_shft1_co;
logic	[8:0]	div_exp1;
logic	[7:0]	div_exp2, div_exp3;
logic		left_right, lr_mul, lr_div;
logic	[7:0]	shift_right, shftr_mul, shftr_div;
logic	[7:0]	shift_left,  shftl_mul, shftl_div;
logic	[7:0]	fasu_shift;
logic	[7:0]	exp_fix_div;

logic	[7:0]	exp_fix_diva, exp_fix_divb;
logic	[5:0]	fi_ldz_mi1;
logic	[5:0]	fi_ldz_mi22;
logic		exp_zero;		
logic	[6:0]	ldz_all;
logic	[7:0]	ldz_dif;

logic	[8:0]	div_scht1a;
logic	[7:0]	f2i_shft;
logic	[55:0]	exp_f2i_1;
logic		f2i_zero, f2i_max;
logic	[7:0]	f2i_emin;
logic	[7:0]	conv_shft;
logic	[7:0]	exp_i2f, exp_f2i, conv_exp;
logic 		round2_f2i;

// Normalize and Round logic

// Count Leading zeros in Fraction by using always_comb and unique case 

always_comb begin
    unique casez (fract_in)  // 'casez' allows "?" for dont care bits
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
	default: fi_ldz = 48; //Default case to handle all zeros
	endcase
end

// Normalize

logic		exp_in_80;
logic		rmode_00, rmode_01, rmode_10, rmode_11;

// Misc common signals
always_comb begin
 exp_in_ff        = &exp_in;
 exp_in_00        = !(|exp_in);
 exp_in_80	= exp_in[7] & !(|exp_in[6:0]);
 exp_out_ff       = &exp_out;
 exp_out_00       = !(|exp_out);
 exp_out_fe       = &exp_out[7:1] & !exp_out[0];
 exp_out_final_ff = &exp_out_final;

 fract_out_7fffff = &fract_out;
 fract_out_00     = !(|fract_out);
 fract_in_00      = !(|fract_in);

 rmode_00 = (rmode==2'b00);
 rmode_01 = (rmode==2'b01);
 rmode_10 = (rmode==2'b10);
 rmode_11 = (rmode==2'b11);

// Fasu Output will be denormalized ...
 dn = !op_mul & !op_div & (exp_in_00 | (exp_next_mi[8] & !fract_in[47]) );
 end
 
 // Fraction Normalization
parameter	f2i_emax = 8'h9d;

//Signals for f2i
always_comb begin 
     fract_out_pl1 = fract_out + 1; // Incremented fraction for rounding
	 f2i_emin = rmode_00 ? 8'h7e : 8'h7f;
	 //f2i zero signal
	 f2i_zero = (!opas & (exp_in<f2i_emin)) | 
	            (opas & (exp_in>f2i_emax)) | 
				(opas & (exp_in<f2i_emin) & (fract_in_00 | !rmode_11));
	// f2i_max signal
	 f2i_max = (!opas & (exp_in>f2i_emax)) | 
	            (opas & (exp_in<f2i_emin) & !fract_in_00 & rmode_11);
end

// calculating various shifting options
always_comb  begin 
// shift and carry logic 
     {shft_co,shftr_mul} = (!exp_ovf[1] & exp_in_00) ? {1'b0, exp_out} : exp_in_mi1 ;
     {div_shft1_co, div_shft1} = exp_in_00 ? {1'b0, div_opa_ldz} : div_scht1a;
	 
// Division shift and carry logic 
     div_scht1a = exp_in-div_opa_ldz; // 9 bits - includes carry out
     div_shft2  = exp_in+2;
     div_shft3  = div_opa_ldz+exp_in;
     div_shft4  = div_opa_ldz-exp_in;
	 
// Division denormalization snd overflow logic 
    div_dn    = op_dn & div_shft1_co;
    div_nr    = op_dn & exp_ovf[1]  & !(|fract_in[46:23]) & (div_shft3>8'h16);
	
//fraction to integer shift logic 
     f2i_shft  = exp_in-8'h7d;
end

//Select shifting direction
always_comb begin
    left_right = op_div ? lr_div : op_mul ? lr_mul : 1; // selecting left or right shift direction based on operation type
// logic for lr_div calculation
	lr_div = (op_dn & !exp_ovf[1] & exp_ovf[0]) ? 1 :(op_dn & exp_ovf[1]) ? 0 :(op_dn & div_shft1_co) ? 0 :(op_dn & exp_out_00) ? 1 :(!op_dn & exp_out_00 & !exp_ovf[1]) ? 1 :exp_ovf[1] ? 0 : 1;
// logic for lr_mul calculation
	lr_mul 	= (shft_co | (!exp_ovf[1] & exp_in_00) |(!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00) )) ? 1 :( exp_ovf[1] | exp_in_00 ) ?	0 :1;
	
end

// Select Left and Right shift value
always_comb begin 
    fasu_shift  = (dn | exp_out_00) ? (exp_in_00 ? 8'h2 : exp_in_pl1[7:0]) : {2'h0, fi_ldz};
	shift_right = op_div ? shftr_div : shftr_mul;
	conv_shft = op_f2i ? f2i_shft : {2'h0, fi_ldz};
	shift_left  = op_div ? shftl_div : op_mul ? shftl_mul : (op_f2i | op_i2f) ? conv_shft : fasu_shift;
end
//left shift logic for multiplication
always_comb begin
    shftl_mul = 	(shft_co |
			(!exp_ovf[1] & exp_in_00) |(!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00))) ? exp_in_pl1[7:0] : {2'h0, fi_ldz};
end

// left shift logic for Division
always_comb begin 
    shftl_div = 	( op_dn & exp_out_00 & !(!exp_ovf[1] & exp_ovf[0]))	? div_shft1[7:0] :(!op_dn & exp_out_00 & !exp_ovf[1])    			? exp_in[7:0] : {2'h0, fi_ldz};
 end
 

//Right shift logic for Division
always_comb begin
    assign shftr_div = 	(op_dn & exp_ovf[1])? div_shft3 :(op_dn & div_shft1_co)? div_shft4 : div_shft2;
end

// perform the actual shifting: right shift
always_comb begin 
    fract_in_shftr   = (|shift_right[7:6]) ? 0 : fract_in>>shift_right[5:0]; 
end

//perform the actual shifting: left shift 
always_comb begin
    fract_in_shftl   = (|shift_left[7:6] | (f2i_zero & op_f2i)) ? 0 : fract_in<<shift_left[5:0];
end

// choose the final fraction output which is based on he shift direction
always_comb begin
    {fract_out,fract_trunc} = left_right ? fract_in_shftl : fract_in_shftr;
end

//Exponnent Normalization
always_comb begin
     fi_ldz_mi1    = fi_ldz - 1;
     fi_ldz_mi22   = fi_ldz - 22;
     exp_out_pl1   = exp_out + 1;
     exp_out_mi1   = exp_out - 1;
     exp_in_pl1    = exp_in  + 1;	// 9 bits - includes carry out
     exp_in_mi1    = exp_in  - 1;	// 9 bits - includes carry out
     exp_out1_mi1  = exp_out1 - 1;
     exp_next_mi  = exp_in_pl1 - fi_ldz_mi1;	// 9 bits - includes carry out
     exp_fix_diva = exp_in - fi_ldz_mi22;
     exp_fix_divb = exp_in - fi_ldz_mi1;
     exp_zero  = (exp_ovf[1] & !exp_ovf[0] & op_mul & (!exp_rnd_adj2a | !rmode[1])) | (op_mul & exp_out1_co); 
	{exp_out1_co, exp_out1} = fract_in[47] ? exp_in_pl1 : exp_next_mi;
     f2i_out_sign =  !opas ? ((exp_in<f2i_emin) ? 0 : (exp_in>f2i_emax) ? 0 : opas) : ((exp_in<f2i_emin) ? 0 : (exp_in>f2i_emax) ? 1 : opas);
     exp_i2f   = fract_in_00 ? (opas ? 8'h9e : 0) : (8'h9e-fi_ldz);
     exp_f2i_1 = {{8{fract_in[47]}}, fract_in }<<f2i_shft;
     exp_f2i   = f2i_zero ? 0 : f2i_max ? 8'hff : exp_f2i_1[55:48];
     conv_exp  = op_f2i ? exp_f2i : exp_i2f;

     exp_out = op_div ? exp_div : (op_f2i | op_i2f) ? conv_exp : exp_zero ? 8'h0 : dn ? {6'h0, fract_in[47:46]} : exp_out1;
end

// calculate ldz_all, ldz_dif, fi_ldz_2a, fi_ldz_2

always_comb begin
    ldz_all   = div_opa_ldz + fi_ldz;
	ldz_dif   = fi_ldz_2 - div_opa_ldz;
    fi_ldz_2a = 6'd23 - fi_ldz;
    fi_ldz_2  = {fi_ldz_2a[6], fi_ldz_2a[6:0]};
end

// calculate div_exp1, div_exp2, div_exp3
always_comb begin
    div_exp1  = exp_in_mi1 + fi_ldz_2;	// 9 bits - includes carry out
    div_exp2  = exp_in_pl1 - ldz_all;
    div_exp3  = exp_in + ldz_dif;;
end

//exponent for Division
always_comb begin
exp_div = (opa_dn & opb_dn)	? div_exp3 :opb_dn ? div_exp1[7:0] :(opa_dn & !( (exp_in<div_opa_ldz) | (div_exp2>9'hfe) ))	? div_exp2 :(opa_dn | (exp_in_00 & !exp_ovf[1]) )? 0 :  exp_out1_mi1;
	
end

// To handle division infinity condition
always_comb begin
    div_inf = opb_dn & !opa_dn & (div_exp1[7:0] < 8'h7f);
end

//round
// Extract rounding bits (GRS) bits
always_comb begin
     grs_sel_div = op_div & (exp_ovf[1] | div_dn | exp_out1_co | exp_out_00);
     g = grs_sel_div ? fract_out[0]                   : fract_out[0];
     r = grs_sel_div ? (fract_trunc[24] & !div_nr)    : fract_trunc[24];
     s = grs_sel_div ? |fract_trunc[24:0]             : (|fract_trunc[23:0] | (fract_trunc[24] & op_div));
end

// To Round to nearest even
always_comb begin
      round = (g & r) | (r & s) ;
      {exp_rnd_adj0, fract_out_rnd0} = round ? fract_out_pl1 : {1'b0, fract_out};
       exp_out_rnd0 =  exp_rnd_adj0 ? exp_out_pl1 : exp_out;
      ovf0 = exp_out_final_ff & !rmode_01 & !op_f2i;
end

// To Round to zero
always_comb begin
     fract_out_rnd1 = (exp_out_ff & !op_div & !dn & !op_f2i) ? 23'h7fffff : fract_out;
     exp_fix_div    = (fi_ldz>22) ? exp_fix_diva : exp_fix_divb;
     exp_out_rnd1   = (g & r & s & exp_in_ff) ? (op_div ? exp_fix_div : exp_next_mi[7:0]) :(exp_out_ff & !op_f2i) ? exp_in : exp_out;
     ovf1 = exp_out_ff & !dn;
end

// To round to +inf (UP) and -inf (DOWN)
always_comb begin 
    r_sign = sign;
    round2a = !exp_out_fe | !fract_out_7fffff | (exp_out_fe & fract_out_7fffff); //conditions for rounding to +inf or -inf
    round2_fasu = ((r | s) & !r_sign) & (!exp_out[7] | (exp_out[7] & round2a));
	
	 round2_fmul = !r_sign & 
		(
			(exp_ovf[1] & !fract_in_00 &
				( ((!exp_out1_co | op_dn) & (r | s | (!rem_00 & op_div) )) | fract_out_00 | (!op_dn & !op_div))
			 ) |
			(
				(r | s | (!rem_00 & op_div)) & (
						(!exp_ovf[1] & (exp_in_80 | !exp_ovf[0])) | op_div |
						( exp_ovf[1] & !exp_ovf[0] & exp_out1_co)
					)
			)
		);
    round2_f2i = rmode_10 & (( |fract_in[23:0] & !opas & (exp_in<8'h80 )) | (|fract_trunc));
    round2 = (op_mul | op_div) ? round2_fmul : op_f2i ? round2_f2i : round2_fasu; // To select the round type based on operation
end
 
 // Rounding adjustments for fraction and exponent
 always_comb begin
    {exp_rnd_adj2a, fract_out_rnd2a} = round2 ? fract_out_pl1 : {1'b0, fract_out};
    exp_out_rnd2a  = exp_rnd_adj2a ? ((exp_ovf[1] & op_mul) ? exp_out_mi1 : exp_out_pl1) : exp_out;
end

// final fraction rounding and exponent adjustments
always_comb begin 
    fract_out_rnd2 = (r_sign & exp_out_ff & !op_div & !dn & !op_f2i) ? 23'h7fffff : fract_out_rnd2a;
    exp_out_rnd2   = (r_sign & exp_out_ff & !op_f2i) ? 8'hfe      : exp_out_rnd2a;
end
 
// To choose rounding mode for exp_out 
always_comb begin
    case (rmode) 
	0    : exp_out_rnd = exp_out_rnd0;
	1    : exp_out_rnd = exp_out_rnd1;
	2,3  : exp_out_rnd = exp_out_rnd2;
	default : exp_out_rnd = exp_out_rnd0; // default case to avoid latches
    endcase
end

// To choose rounding mode for fracta_out 
always_comb begin 
    case(rmode) 
     0   : fract_out_rnd = fract_out_rnd0;
	 1   : fract_out_rnd = fract_out_rnd1;
	 2,3 : fract_out_rnd = fract_out_rnd2;
	endcase
end

// For final output MUX and Handling special numbers

logic max_num, inf_out;

always_comb begin
     max_num =  ( !rmode_00 & (op_mul | op_div ) & (
							  ( exp_ovf[1] &  exp_ovf[0]) |
							  (!exp_ovf[1] & !exp_ovf[0] & exp_in_ff & (fi_ldz_2<24) & (exp_out!=8'hfe) )
							  )
		   ) |

		   ( op_div & (
				   ( rmode_01 & ( div_inf |
							 (exp_out_ff & !exp_ovf[1] ) |
							 (exp_ovf[1] &  exp_ovf[0] )
						)
				   ) |
		
				   ( rmode[1] & !exp_ovf[1] & (
								   ( exp_ovf[0] & exp_in_ff & r_sign & fract_in[47]
								   ) |
						
								   (  r_sign & (
										(fract_in[47] & div_inf) |
										(exp_in[7] & !exp_out_rnd[7] & !exp_in_80 & exp_out!=8'h7f ) |
										(exp_in[7] &  exp_out_rnd[7] & r_sign & exp_out_ff & op_dn &
											 div_exp1>9'h0fe )
										)
								   ) |

								   ( exp_in_00 & r_sign & (
												div_inf |
												(r_sign & exp_out_ff & fi_ldz_2<24)
											  )
								   )
							       )
				  )
			    )
		   );

end


// To calculate inf_out 
always_comb begin
    inf_out = (rmode[1] & (op_mul | op_div) & !r_sign & (	(exp_in_ff & !op_div) |
								(exp_ovf[1] & exp_ovf[0] & (exp_in_00 | exp_in[7]) ) 
							   )
		) | (div_inf & op_div & (
				 rmode_00 |
				(rmode[1] & !exp_in_ff & !exp_ovf[1] & !exp_ovf[0] & !r_sign ) |
				(rmode[1] & !exp_ovf[1] & exp_ovf[0] & exp_in_00 & !r_sign)
				)
		) | (op_div & rmode[1] & exp_in_ff & op_dn & !r_sign & (fi_ldz_2 < 24)  & (exp_out_rnd!=8'hfe) );
end

// Final Output for fract_out_final 
always_comb begin
   fract_out_final =	(inf_out | ovf0 | output_zero ) ? 23'h0 :
				(max_num | (f2i_max & op_f2i) ) ? 23'h7fffff :
				fract_out_rnd;
end

// Final Output for exp_out_final
always_comb begin 
    if ((op_div & exp_ovf[1] & !exp_ovf[0]) | output_zero ) begin 
	exp_out_final = 8'h00;
	end else if ((op_div & exp_ovf[1] &  exp_ovf[0] & rmode_00) | inf_out | (f2i_max & op_f2i) ) begin
	exp_out_final = 8'hff;
	end else if (max_num) begin 
	exp_out_final = 8'hfe;
	end else begin 
	exp_out_final = exp_out_rnd;
	end
end

//Final Output Mux : Pack Result

always_comb begin 
    out = {exp_out_final, fract_out_final};
end

//Exceptions

// intermediate signals
logic underflow_fmul, overflow_fdiv, undeflow_div, z, f2i_ine;

always_comb begin  // To Define the Z signal 
    z =	shft_co | ( exp_ovf[1] |  exp_in_00) |
			(!exp_ovf[1] & !exp_in_00 & (exp_out1_co | exp_out_00));
end

 always_comb begin // To calculate underflow_fmul 
    underflow_fmul = ( (|fract_trunc) & z & !exp_in_ff ) |
			(fract_out_00 & !fract_in_00 & exp_ovf[1]);
end

always_comb begin  //To calculate undeflow_div
  undeflow_div =  !(exp_ovf[1] &  exp_ovf[0] & rmode_00) & !inf_out & !max_num & exp_out_final!=8'hff & (                                        ///////////////under_div

			((|fract_trunc) & !opb_dn & (
							( op_dn & !exp_ovf[1] & exp_ovf[0])	|
							( op_dn &  exp_ovf[1])			|
							( op_dn &  div_shft1_co)		| 
							  exp_out_00				|
							  exp_ovf[1]
						  )

			) |

			( exp_ovf[1] & !exp_ovf[0] & (
							(  op_dn & exp_in>8'h16 & fi_ldz<23) |
							(  op_dn & exp_in<23 & fi_ldz<23 & !rem_00) |
							( !op_dn & (exp_in[7]==exp_div[7]) & !rem_00) |
							( !op_dn & exp_in_00 & (exp_div[7:1]==7'h7f) ) |
							( !op_dn & exp_in<8'h7f & exp_in>8'h20 )
							)
			) |

			(!exp_ovf[1] & !exp_ovf[0] & (
							( op_dn & fi_ldz<23 & exp_out_00) |
							( exp_in_00 & !rem_00) |
							( !op_dn & ldz_all<23 & exp_in==1 & exp_out_00 & !rem_00)
							)
			)

			);
end

// to calculate underflow based on operations type
always_comb begin 
  underflow =  op_div ? undeflow_div : op_mul ? underflow_fmul : (!fract_in[47] & exp_out1_co) & !dn;          //////////////////////////////////////////underflow
end

// To calculate overflow_fdiv
always_comb begin 
	overflow_fdiv =	inf_out |
			(!rmode_00 & max_num) |
			(exp_in[7] & op_dn & exp_out_ff) |
			(exp_ovf[0] & (exp_ovf[1] | exp_out_ff) );
end

// To calculate overflow 
always_comb begin 
    overflow  = op_div ? overflow_fdiv : (ovf0 | ovf1);
end

// To calculate f2i_line 
always_comb begin 
    f2i_ine =	(f2i_zero & !fract_in_00 & !opas) |
			(|fract_trunc) |
			(f2i_zero & (exp_in<8'h80) & opas & !fract_in_00) |
			(f2i_max & rmode_11 & (exp_in<8'h80));
end

// to calculate based on operation type 
always_comb begin 
    ine = op_f2i ? f2i_ine :
		op_i2f ? (|fract_trunc) :
		((r & !dn) | (s & !dn) | max_num | (op_div & !rem_00));
end

// Debugging 
// Defining wires for debugging 

logic	[26:0]	fracta_del, fractb_del;
logic	[2:0]	grs_del;
logic		dn_del;
logic	[7:0]	exp_in_del, exp_out_del;
logic 	[22:0]	fract_out_del;
logic	[47:0]	fract_in_del;
logic		overflow_del;
logic	[1:0]	exp_ovf_del;
logic	[22:0]	fract_out_x_del, fract_out_rnd2a_del;
logic	[24:0]	trunc_xx_del;
logic 		exp_rnd_adj2a_del;
logic	[22:0]	fract_dn_del;
logic	[4:0]	div_opa_ldz_del;
logic	[23:0]	fracta_div_del;
logic	[23:0]	fractb_div_del;
logic		div_inf_del;
logic	[7:0]	fi_ldz_2_del;
logic		inf_out_del, max_out_del;
logic	[5:0]	fi_ldz_del;
logic		rx_del;
logic		ez_del;
logic		lr;
logic	[7:0]	shr, shl, exp_div_del;

delay2 #(.N(26)) ud000 (.clk(clk), .in(test.u0.fracta), .out(fracta_del));
delay2 #(.N(26)) ud001 (.clk(clk), .in(test.u0.fractb), .out(fractb_del));
delay1 #(.N(2)) ud002 (.clk(clk), .in({g, r, s}), .out(grs_del));
delay1 #(.N(0)) ud004 (.clk(clk), .in(dn), .out(dn_del));
delay1 #(.N(7)) ud005 (.clk(clk), .in(exp_in), .out(exp_in_del));
delay1 #(.N(7)) ud007 (.clk(clk), .in(exp_out_rnd), .out(exp_out_del));
delay1 #(.N(47)) ud009 (.clk(clk), .in(fract_in), .out(fract_in_del));
delay1 #(.N(0)) ud010 (.clk(clk), .in(overflow), .out(overflow_del));
delay1 #(.N(1)) ud011 (.clk(clk), .in(exp_ovf), .out(exp_ovf_del));
delay1 #(.N(22)) ud014 (.clk(clk), .in(fract_out), .out(fract_out_x_del));
delay1 #(.N(24)) ud015 (.clk(clk), .in(fract_trunc), .out(trunc_xx_del));
delay1 #(.N(0)) ud017 (.clk(clk), .in(exp_rnd_adj2a), .out(exp_rnd_adj2a_del));
delay1 #(.N(4)) ud019 (.clk(clk), .in(div_opa_ldz), .out(div_opa_ldz_del));
delay3 #(.N(23)) ud020 (.clk(clk), .in(test.u0.fdiv_opa[49:26]), .out(fracta_div_del));
delay3 #(.N(23)) ud021 (.clk(clk), .in(test.u0.fractb_mul), .out(fractb_div_del));
delay1 #(.N(0)) ud023 (.clk(clk), .in(div_inf), .out(div_inf_del));
delay1 #(.N(7)) ud024 (.clk(clk), .in(fi_ldz_2), .out(fi_ldz_2_del));
delay1 #(.N(0)) ud025 (.clk(clk), .in(inf_out), .out(inf_out_del));
delay1 #(.N(0)) ud026 (.clk(clk), .in(max_num), .out(max_num_del));
delay1 #(.N(5)) ud027 (.clk(clk), .in(fi_ldz), .out(fi_ldz_del));
delay1 #(.N(0)) ud028 (.clk(clk), .in(rem_00), .out(rx_del));

delay1 #(.N(0)) ud029 (.clk(clk), .in(left_right), .out(lr));
delay1 #(.N(7)) ud030 (.clk(clk), .in(shift_right), .out(shr));
delay1 #(.N(7)) ud031 (.clk(clk), .in(shift_left), .out(shl));
delay1 #(.N(22)) ud032 (.clk(clk), .in(fract_out_rnd2a), .out(fract_out_rnd2a_del));

delay1 #(.N(7)) ud033 (.clk(clk), .in(exp_div), .out(exp_div_del));

always_ff @(posedge test.error_event) begin 
    $display("\n----------------------------------------------");
	
	$display("ERROR: GRS: %b exp_ovf: %b dn: %h exp_in: %h exp_out: %h, exp_rnd_adj2a: %b", grs_del, exp_ovf_del, dn_del, exp_in_del, exp_out_del, exp_rnd_adj2a_del);
	
	$display("      div_opa: %b, div_opb: %b, rem_00: %b, exp_div: %h", fracta_div_del, fractb_div_del, rx_del, exp_div_del);
	
	$display("      lr: %b, shl: %h, shr: %h", lr, shl, shr);
	
	$display("       overflow: %b, fract_in=%b  fa:%h fb:%h", overflow_del, fract_in_del, fracta_del, fractb_del);

	$display("       div_opa_ldz: %h, div_inf: %b, inf_out: %b, max_num: %b, fi_ldz: %h, fi_ldz_2: %h", div_opa_ldz_del, div_inf_del, inf_out_del, max_num_del, fi_ldz_del, fi_ldz_2_del);

    $display("       fract_out_x: %b, fract_out_rnd2a_del: %h, fract_trunc: %b\n", fract_out_x_del, fract_out_rnd2a_del, trunc_xx_del);

end 

// Delay modules 
module delay1 #(parameter N = 1) (input logic clk, input logic [N:0] in, output logic [N:0] out);
    always_ff @(posedge clk) begin 
	out <= #1 in;
	end
endmodule

module delay2 #(parameter N = 1) (input logic clk, input logic [N:0] in, output logic [N:0] out);
logic [N:0] r1;
    always_ff @(posedge clk) begin 
	r1 <= #1 in;
	end
	
	always_ff @(posedge clk) begin 
	out <= #1 r1;
	end
endmodule

module delay3 #(parameter N = 1) (input logic clk, input logic [N:0] in, output logic [N:0] out);
logic [N:0] r1,r2;
 always_ff @(posedge clk) begin 
	r1 <= #1 in;
	end

always_ff @(posedge clk) begin 
	r2 <= #1 r1;
	end

always_ff @(posedge clk) begin 
	out  <= #1 r2;
	end
	
endmodule





endmodule









	




