/* ECE 571 Group 17 Project
** V->SV conversion
** Original by Rudolf Usselmann
*/

`timescale 1ns / 100ps

module pre_norm_fmul(
input logic clk,
input logic [2:0] fpu_op,
input logic [31:0] opa, opb,
output logic [23:0] fracta, fractb,
output logic [7:0] exp_out,
output logic sign, sign_exe,
output logic inf,
output logic [1:0] exp_ovf,
output logic [2:0] underflow
);


////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//


wire logic		signa, signb;
logic		sign_d;


wire logic	[1:0]	exp_ovf_d;

wire logic	[7:0]	expa, expb;
wire logic	[7:0]	exp_tmp1, exp_tmp2;
wire logic		co1, co2;
wire logic		expa_dn, expb_dn;
wire logic	[7:0]	exp_out_a;
wire logic		opa_00, opb_00, fracta_00, fractb_00;
wire logic	[7:0]	exp_tmp3, exp_tmp4, exp_tmp5;
wire logic	[2:0]	underflow_d;

wire logic		op_div = (fpu_op == 3'b011);
wire logic	[7:0]	exp_out_mul, exp_out_div;

////////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign  signa = opa[31];
assign  signb = opb[31];
assign   expa = opa[30:23];
assign   expb = opb[30:23];

////////////////////////////////////////////////////////////////////////
//
// Calculate Exponenet
//

assign expa_dn   = !(|expa);
assign expb_dn   = !(|expb);
assign opa_00    = !(|opa[30:0]);
assign opb_00    = !(|opb[30:0]);
assign fracta_00 = !(|opa[22:0]);
assign fractb_00 = !(|opb[22:0]);

assign fracta = {!expa_dn,opa[22:0]};	// Recover hidden bit
assign fractb = {!expb_dn,opb[22:0]};	// Recover hidden bit

assign {co1,exp_tmp1} = op_div ? (expa - expb)            : (expa + expb);
assign {co2,exp_tmp2} = op_div ? ({co1,exp_tmp1} + 8'h7f) : ({co1,exp_tmp1} - 8'h7f);

assign exp_tmp3 = exp_tmp2 + 1;
assign exp_tmp4 = 8'h7f - exp_tmp1;
assign exp_tmp5 = op_div ? (exp_tmp4+1) : (exp_tmp4-1);


always_ff @(posedge clk) begin
	exp_out <= #1 op_div ? exp_out_div : exp_out_mul;
end

assign exp_out_div = (expa_dn | expb_dn) ? (co2 ? exp_tmp5 : exp_tmp3 ) : co2 ? exp_tmp4 : exp_tmp2;
assign exp_out_mul = exp_ovf_d[1] ? exp_out_a : (expa_dn | expb_dn) ? exp_tmp3 : exp_tmp2;
assign exp_out_a   = (expa_dn | expb_dn) ? exp_tmp5 : exp_tmp4;
assign exp_ovf_d[0] = op_div ? (expa[7] & !expb[7]) : (co2 & expa[7] & expb[7]);
assign exp_ovf_d[1] = op_div ? co2                  : ((!expa[7] & !expb[7] & exp_tmp2[7]) | co2);

always_ff @(posedge clk) begin
	exp_ovf <= #1 exp_ovf_d;
end

assign underflow_d[0] =	(exp_tmp1 < 8'h7f) & !co1 & !(opa_00 | opb_00 | expa_dn | expb_dn);
assign underflow_d[1] =	((expa[7] | expb[7]) & !opa_00 & !opb_00) |
			 (expa_dn & !fracta_00) | (expb_dn & !fractb_00);
assign underflow_d[2] =	 !opa_00 & !opb_00 & (exp_tmp1 == 8'h7f);

always_ff @(posedge clk) begin
	underflow <= #1 underflow_d;
	inf <= #1 op_div ? (expb_dn & !expa[7]) : ({co1,exp_tmp1} > 9'h17e) ;
end

////////////////////////////////////////////////////////////////////////
//
// Determine sign for the output
//

// sign: 0=Posetive Number; 1=Negative Number
always_comb begin
   case({signa, signb})
	2'b0_0: sign_d = 0;
	2'b0_1: sign_d = 1;
	2'b1_0: sign_d = 1;
	2'b1_1: sign_d = 0;
   endcase
end
always_ff @(posedge clk) begin
	sign <= #1 sign_d;
	sign_exe <= #1 signa & signb;
end
endmodule
