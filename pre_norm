`timescale 1ns / 100ps
 module pre_norm (
    input logic           clk,
    input logic [1:0]     rmode,
    input logic           add,
    input logic [31:0]    opa, opb, 
    input logic           opa_nan, opb_nan,
    output logic [26:0]   fracta_out,
    output logic [26:0]   fractb_out,
    output logic [7:0]    exp_dn_out,
    output logic          sign,
    output logic          nan_sign,
    output logic          result_zero_sign,
    output logic          fasu_op
	);
	
// Local wires and registers
logic signa, signb;
logic [7:0]	expa, expb;
logic [22:0]fracta, fractb;
logic       expa_lt_expb;	
logic       fractb_lt_fracta;

logic [7:0] exp_small, exp_large;
logic [7:0]	exp_diff, exp_diff1, exp_diff1a, exp_diff2;

logic [22:0]	adj_op;	
logic [26:0]	adj_op_tmp;
logic [26:0]	adj_op_out;
logic [26:0]	fracta_n, fractb_n;
logic [26:0]	fracta_s, fractb_s;
logic            sign_d;
logic           add_d;
logic           expa_dn, expb_dn;
logic           sticky;
logic           add_r, signa_r, signb_r;
logic           [4:0]	exp_diff_sft;
logic           exp_lt_27;
logic           op_dn;
logic           [26:0]	adj_op_out_sft;
logic           fracta_lt_fractb, fracta_eq_fractb;
logic           nan_sign1;


// Aliases
always_comb begin 
  signa = opa[31];
  signb = opb[31];
  expa = opa[30:23];
  expb = opb[30:23];
  fracta = opa[22:0];
  fractb = opb[22:0];
 end

// Pre-Normalize exponents (and fractions)
always_comb begin
 expa_lt_expb = expa > expb;		// expa is larger than expb
 expa_dn = !(|expa);			// opa denormalized
 expb_dn = !(|expb);			// opb denormalized
end
// // Calculate the difference between the smaller and larger exponent
always_comb begin
 exp_small  = expa_lt_expb ? expb : expa;
 exp_large  = expa_lt_expb ? expa : expb;
 exp_diff1  = exp_large - exp_small;
 exp_diff1a = exp_diff1-1;
 exp_diff2  = (expa_dn | expb_dn) ? exp_diff1a : exp_diff1;
 exp_diff  = (expa_dn & expb_dn) ? 8'h0 : exp_diff2;
end

always_ff @(posedge clk) begin
if (!add_d && (expa==expb) & (fracta==fractb))
    exp_dn_out <= 8'h00;
else 
    exp_dn_out <= exp_large;
end

 // Adjust the smaller fraction
always_comb begin 
 op_dn	  = expa_lt_expb ? expb_dn : expa_dn;
 adj_op     = expa_lt_expb ? fractb : fracta;
 adj_op_tmp = { ~op_dn, adj_op, 3'b0 };	
 exp_lt_27	= exp_diff  > 8'd27;
 exp_diff_sft	= exp_lt_27 ? 5'd27 : exp_diff[4:0];
 adj_op_out_sft	= adj_op_tmp >> exp_diff_sft;
 adj_op_out	= {adj_op_out_sft[26:1], adj_op_out_sft[0] | sticky };
end

// sticky bit : usisng always comb and default statement to take all the possible values
always_comb begin
     sticky = 1'b0;
     case (exp_diff_sft)
          5'd0 : sticky = 1'b0;
		  5'd1 : sticky =  adj_op_tmp[0]; 
		  5'd2 : sticky =  |adj_op_tmp[1:0];
		  5'd3 : sticky =  |adj_op_tmp[2:0];
		  5'd4 : sticky =  |adj_op_tmp[3:0];
		  5'd5 : sticky =  |adj_op_tmp[4:0];
		  5'd6 : sticky =  |adj_op_tmp[5:0];
		  5'd7 : sticky =  |adj_op_tmp[6:0];
          5'd8 : sticky =  |adj_op_tmp[7:0];
		  5'd9 : sticky =  |adj_op_tmp[8:0];
		  5'd10 : sticky =  |adj_op_tmp[9:0];
		  5'd11 : sticky =  |adj_op_tmp[10:0];
		  5'd12 : sticky =  |adj_op_tmp[11:0];
		  5'd13 : sticky =  |adj_op_tmp[12:0];
		  5'd14 : sticky =  |adj_op_tmp[13:0];
		  5'd15 : sticky =  |adj_op_tmp[14:0];
		  5'd16 : sticky =  |adj_op_tmp[15:0];
		  5'd17 : sticky =  |adj_op_tmp[16:0];
		  5'd18 : sticky =  |adj_op_tmp[17:0];
		  5'd19 : sticky =  |adj_op_tmp[18:0];
		  5'd20 : sticky =  |adj_op_tmp[19:0];
		  5'd21 : sticky =  |adj_op_tmp[20:0];
		  5'd22 : sticky =  |adj_op_tmp[21:0];
		  5'd23 : sticky =  |adj_op_tmp[22:0];
		  5'd24 : sticky =  |adj_op_tmp[23:0];
		  5'd25 : sticky =  |adj_op_tmp[24:0];
		  5'd26 : sticky =  |adj_op_tmp[25:0];
		  5'd27 : sticky =  |adj_op_tmp[26:0];
		  default: sticky = 1'b0;
     endcase
 end
 
 always_comb begin
    fracta_n = expa_lt_expb ? {~expa_dn, fracta, 3'b0} : adj_op_out;
	fractb_n = expa_lt_expb ? adj_op_out : {~expb_dn, fractb, 3'b0};
end

always_ff @(posedge clk) begin
         fracta_out <= fracta_s;
		 fractb_out <= fractb_s;
     end
	 
	
// determine sign used a unique case 
always_comb begin
     unique case ({signa, signb, add})
	     3'b000: sign_d = fractb_lt_fracta; 
		 3'b001: sign_d = 1'b0;
		 3'b010: sign_d = 1'b1;
		 3'b011: sign_d = !fractb_lt_fracta; 
		 3'b100: sign_d = !fractb_lt_fracta; 
		 3'b101: sign_d = 1'b1;
		 3'b110: sign_d = 1'b0;
		 3'b111: sign_d = fractb_lt_fracta; 
	endcase
end

// used always_ff block for fixing sign for ZERO Result

always_ff @(posedge clk) begin
        sign <= sign_d;
		signa_r <= signa;
		signb_r <= signb;
		add_r <= add;
		result_zero_sign <= ( add_r &  signa_r &  signb_r) |
				(!add_r &  signa_r & ~signb_r) |
				( add_r & (signa_r |  signb_r) & (rmode==2'b11)) |
				(!add_r & (signa_r == signb_r) & (rmode==2'b11));
end

//used always_ff block for fixing for NAN Result

always_ff @(posedge clk) begin 
    fracta_lt_fractb <=  fracta < fractb;
	fracta_eq_fractb <=  fracta == fractb;
end

always_comb begin 
    nan_sign1 = fracta_eq_fractb ? (signa_r & signb_r) : fracta_lt_fractb ? signb_r : signa_r;
end

always_ff @(posedge clk) begin 
        nan_sign <= #1 (opa_nan & opb_nan) ? nan_sign1 : opb_nan ? signb_r : signa_r;
	end
	
// used always_comb for Decode add/sub operation with unique case

always_comb begin
unique case ({signa, signb, add})
         3'b000: add_d = 1'b0; 
		 3'b001: add_d = 1'b1;
		 3'b010: add_d = 1'b1;
		 3'b011: add_d = 1'b0;
		 3'b100: add_d = 1'b0;
		 3'b101: add_d = 1'b1;
		 3'b110: add_d = 1'b1;
		 3'b111: add_d = 1'b0;
	endcase
end
//used always_ff block
always_ff @(posedge clk) begin 
fasu_op <= add_d;
end
endmodule


	
	

     
		

		
		 
		 
		 
		 

 



