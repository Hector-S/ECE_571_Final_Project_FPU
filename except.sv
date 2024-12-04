`timescale 1ns / 100ps

module except (
    input  logic        clk,
    input  logic [31:0] opa, opb,
    output logic        inf, ind, qnan, snan, opa_nan, opb_nan,
    output logic        opa_00, opb_00, opa_inf, opb_inf, opa_dn, opb_dn
);
    // stucture
  typedef struct packed {
        logic [7:0] exp;   // Exponent
        logic [22:0] frac; // Fraction
    } operand_t;

operand_t op_a, op_b;
logic expa_ff, expb_ff, infa_f_r, infb_f_r, qnan_r_a, snan_r_a, qnan_r_b, snan_r_b;
logic expa_00, expb_00, fracta_00, fractb_00;
// Aliases
// operand using struct
   assign op_a = '{opa[30:23], opa[22:0]};
    assign op_b = '{opb[30:23], opb[22:0]};
 always_ff @(posedge clk) begin           // used
// for operand A
        expa_ff <= &op_a.exp;
        infa_f_r <= !(|op_a.frac);
        qnan_r_a <= op_a.frac[22];
        snan_r_a <= !op_a.frac[22] & |op_a.frac[21:0];
        expa_00 <= !(|op_a.exp);
        fracta_00 <= !(|op_a.frac);
//  for operand B
        expb_ff <= &op_b.exp;
        infb_f_r <= !(|op_b.frac);
        qnan_r_b <= op_b.frac[22];
        snan_r_b <= !op_b.frac[22] & |op_b.frac[21:0];
        expb_00 <= !(|op_b.exp);
        fractb_00 <= !(|op_b.frac);
// Outputs
        ind <= (expa_ff & infa_f_r) & (expb_ff & infb_f_r);
        inf <= (expa_ff & infa_f_r) | (expb_ff & infb_f_r);
        qnan <= (expa_ff & qnan_r_a) | (expb_ff & qnan_r_b);
        snan <= (expa_ff & snan_r_a) | (expb_ff & snan_r_b);
        opa_nan <= expa_ff & (|op_a.frac);
        opb_nan <= expb_ff & (|op_b.frac);
        opa_inf <= expa_ff & infa_f_r;
        opb_inf <= expb_ff & infb_f_r;
        opa_00 <= expa_00 & fracta_00;
        opb_00 <= expb_00 & fractb_00;
        opa_dn <= expa_00;
        opb_dn <= expb_00;
    end

endmodule
