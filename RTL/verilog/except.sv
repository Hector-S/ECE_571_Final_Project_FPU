`timescale 1ns / 100ps

module except (
input	logic	clk,
input	logic [31:0]opa, opb,
output	logic 	inf, 
output	logic  ind, 
output	logic  qnan, 
output	logic snan, 
output	logic opa_nan, 
output	logic opb_nan,
output	logic 	opa_00, 
output	logic opb_00
output  logic opa_inf, 
output	logic opb_inf,
output  logic opa_dn,
output	logic opb_dn
);

//local wires and registers
logic	[7:0]	expa, expb;		// alias to opX exponent
logic	[22:0]	fracta, fractb;		// alias to opX fraction
logic	expa_ff, infa_f_r, qnan_r_a, snan_r_a;
logic	expb_ff, infb_f_r, qnan_r_b, snan_r_b;
logic		inf, ind, qnan, snan;	// Output registers
logic 	opa_nan, opb_nan;
logic opa_00, opb_00;
logic 	opa_inf, opb_inf;
logic 		opa_dn, opb_dn;

// Aliases
assign   expa = opa[30:23];
assign   expb = opb[30:23];
assign fracta = opa[22:0];
assign fractb = opb[22:0];




always_ff @(posedge clk) begin
expa_ff <=  &expa;
expb_ff <= &expb;

infa_f_r <=  !(|fracta);
infb_f_r <=  !(|fractb);

qnan_r_a <=   fracta[22];
snan_r_a <=  fracta[22] & |fracta[21:0];
qnan_r_b <=   fractb[22];
snan_r_b <=  !fractb[22] & |fractb[21:0];

ind  <= (expa_ff & infa_f_r) & (expb_ff & infb_f_r);
inf  <=  (expa_ff & infa_f_r) | (expb_ff & infb_f_r);

qnan <=  (expa_ff & qnan_r_a) | (expb_ff & qnan_r_b);
snan <=  (expa_ff & snan_r_a) | (expb_ff & snan_r_b);

opa_nan <= &expa & (|fracta[22:0]);
opb_nan <=  &expb & (|fractb[22:0]);

opa_inf <=  (expa_ff & infa_f_r);
opb_inf <=  (expb_ff & infb_f_r);

expa_00 <=  !(|expa);
expb_00 <=  !(|expb);

fracta_00 <=  !(|fracta);
fractb_00 <=  !(|fractb);

opa_00 <=  expa_00 & fracta_00;
opb_00 <=  expb_00 & fractb_00;


opa_dn <=  expa_00;
opb_dn <=  expb_00;
end

endmodule
