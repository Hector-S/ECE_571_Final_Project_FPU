/////////////////////////////////////////////////////////////////////
////                                                             ////
////  EXCEPT                                                     ////
////  Floating Point Exception/Special Numbers Unit              ////
////  ECE 571 Group 17 V->SV conversion
//    Original by 
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////




`timescale 1ns / 100ps


module except(
input logic		clk,
input logic [31:0]	opa, opb,
output logic	inf, ind, qnan, snan, opa_nan, opb_nan,
output logic	opa_00, opb_00,
output logic	opa_inf, opb_inf,
output logic	opa_dn,
output logic	opb_dn
);


////////////////////////////////////////////////////////////////////////
//
// Local Wires and registers
//

logic	[7:0]	expa, expb;		// alias to opX exponent
logic	[22:0]	fracta, fractb;		// alias to opX fraction
logic		expa_ff, infa_f_r, qnan_r_a, snan_r_a;
logic		expb_ff, infb_f_r, qnan_r_b, snan_r_b;
logic		expa_00, expb_00, fracta_00, fractb_00;


////////////////////////////////////////////////////////////////////////
//
// Aliases
//

assign   expa = opa[30:23];
assign   expb = opb[30:23];
assign fracta = opa[22:0];
assign fractb = opb[22:0];

////////////////////////////////////////////////////////////////////////
//
// Determine if any of the input operators is a INF or NAN or any other special number
//

always_ff @(posedge clk) begin
	expa_ff <= #1 &expa;

	expb_ff <= #1 &expb;

	infa_f_r <= #1 !(|fracta);

	infb_f_r <= #1 !(|fractb);

	qnan_r_a <= #1  fracta[22];

	snan_r_a <= #1 !fracta[22] & |fracta[21:0];

	qnan_r_b <= #1  fractb[22];

	snan_r_b <= #1 !fractb[22] & |fractb[21:0];

	ind  <= #1 (expa_ff & infa_f_r) & (expb_ff & infb_f_r);

	inf  <= #1 (expa_ff & infa_f_r) | (expb_ff & infb_f_r);

	qnan <= #1 (expa_ff & qnan_r_a) | (expb_ff & qnan_r_b);

	snan <= #1 (expa_ff & snan_r_a) | (expb_ff & snan_r_b);

	opa_nan <= #1 &expa & (|fracta[22:0]);

	opb_nan <= #1 &expb & (|fractb[22:0]);

	opa_inf <= #1 (expa_ff & infa_f_r);

	opb_inf <= #1 (expb_ff & infb_f_r);

	expa_00 <= #1 !(|expa);

	expb_00 <= #1 !(|expb);

	fracta_00 <= #1 !(|fracta);

	fractb_00 <= #1 !(|fractb);

	opa_00 <= #1 expa_00 & fracta_00;

	opb_00 <= #1 expb_00 & fractb_00;

	opa_dn <= #1 expa_00;

	opb_dn <= #1 expb_00;
end
endmodule
