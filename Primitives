`timescale 1ns / 100ps


////////////////////////////////////////////////////////////////////////
//
// Add/Sub
//

module add_sub27(
    input  logic        add,
    input  logic [26:0] opa,
    input  logic [26:0] opb,
    output logic [26:0] sum,
    output logic        co
);

    assign {co, sum} = add ? (opa + opb) : (opa - opb);

endmodule

////////////////////////////////////////////////////////////////////////
//
// Multiply
//

module mul_r2(
    input  logic        clk,
    input  logic [23:0] opa,
    input  logic [23:0] opb,
    output logic [47:0] prod
);

    logic [47:0] prod1;

    always_ff @(posedge clk) begin
        prod1 <= opa * opb;
        prod  <= prod1;
    end

endmodule

////////////////////////////////////////////////////////////////////////
//
// Divide
//

module div_r2(
    input  logic        clk,
    input  logic [49:0] opa,
    input  logic [23:0] opb,
    output logic [49:0] quo,
    output logic [49:0] rem
);

    logic [49:0] quo1, remainder;

    always_ff @(posedge clk) begin
        quo1      <= opa / opb;
        remainder <= opa % opb;
        quo       <= quo1;
        rem       <= remainder;
    end

endmodule

