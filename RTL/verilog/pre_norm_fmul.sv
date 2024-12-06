`timescale 1ns / 100ps

module pre_norm_fmul(
input	logic	clk,
input	logic [2:0]	fpu_op,
input	logic [31:0]	opa, opb,
output	logic [23:0]	fracta, fractb,
output	logic [7:0]	exp_out,
output	logic	sign, sign_exe,
output	logic	inf,
output	logic [1:0]	exp_ovf,
output	logic [2:0]	underflow
);

// Local Wires and registers
//

logic			signa, signb;
logic			sign_d;
logic 	[1:0]	exp_ovf_d;
logic 	[7:0]	expa, expb;
logic 	[7:0]	exp_tmp1, exp_tmp2;
logic			co1, co2;
logic			expa_dn, expb_dn;
logic 	[7:0]	exp_out_a;
logic			opa_00, opb_00, fracta_00, fractb_00;
logic 	[7:0]	exp_tmp3, exp_tmp4, exp_tmp5;
logic 	[2:0]	underflow_d;
logic			op_div = (fpu_op == 3'b011);
logic	[7:0]	exp_out_mul, exp_out_div;

// Aliases
always_comb begin 
  signa = opa[31];
  signb = opb[31];
  expa = opa[30:23];
  expb = opb[30:23];
end

// To calculate the exponent value

always_comb begin
 expa_dn   = !(|expa);
 expb_dn   = !(|expb);
 opa_00    = !(|opa[30:0]);
 opb_00    = !(|opb[30:0]);
 fracta_00 = !(|opa[22:0]);
 fractb_00 = !(|opb[22:0]);

 fracta = {!expa_dn,opa[22:0]};	// Recover hidden bit
 fractb = {!expb_dn,opb[22:0]};	// Recover hidden bit

 {co1,exp_tmp1} = op_div ? (expa - expb)            : (expa + expb);
 {co2,exp_tmp2} = op_div ? ({co1,exp_tmp1} + 8'h7f) : ({co1,exp_tmp1} - 8'h7f);

 exp_tmp3 = exp_tmp2 + 1;
 exp_tmp4 = 8'h7f - exp_tmp1;
 exp_tmp5 = op_div ? (exp_tmp4+1) : (exp_tmp4-1);
end

always_ff @(posedge clk) begin
	exp_out <= op_div ? exp_out_div : exp_out_mul;
end

always_comb begin 
 exp_out_div = (expa_dn | expb_dn) ? (co2 ? exp_tmp5 : exp_tmp3 ) : co2 ? exp_tmp4 : exp_tmp2;
 exp_out_a   = (expa_dn | expb_dn) ? exp_tmp5 : exp_tmp4;
 exp_ovf_d[0] = op_div ? (expa[7] & !expb[7]) : (co2 & expa[7] & expb[7]);
 exp_ovf_d[1] = op_div ? co2 : ((!expa[7] & !expb[7] & exp_tmp2[7]) | co2);
 exp_out_mul = exp_ovf_d[1] ? exp_out_a : (expa_dn | expb_dn) ? exp_tmp3 : exp_tmp2;
end

always_ff @(posedge clk) begin
exp_ovf <=  exp_ovf_d;
end

always_comb begin 
 underflow_d[0] =	(exp_tmp1 < 8'h7f) & !co1 & !(opa_00 | opb_00 | expa_dn | expb_dn);
 underflow_d[1] =	((expa[7] | expb[7]) & !opa_00 & !opb_00) | (expa_dn & !fracta_00) | (expb_dn & !fractb_00);
 underflow_d[2] =	 !opa_00 & !opb_00 & (exp_tmp1 == 8'h7f);
end

always_ff @(posedge clk) begin
	underflow <=  underflow_d;
	inf <=  op_div ? (expb_dn & !expa[7]) : ({co1,exp_tmp1} > 9'h17e) ;
end

//To determine sign for output 
// sign 0: positive number, sign 1: negative number 

always_comb begin 
   case({signa, signb}) // given the two sign bit into a 2bit concatenation 		
	2'b00: sign_d = 0;
	2'b01: sign_d = 1;
	2'b10: sign_d = 1;
	2'b11: sign_d = 0;
	default sign_d = 0; // not required for a 2bit value its an optional
   endcase
end 


always_ff @(posedge clk)begin 
sign <= sign_d;
sign_exe <= signa & signb;
end

endmodule 



