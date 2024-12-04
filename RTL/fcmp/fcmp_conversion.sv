/* FCMP                                        
** Single precision Floating Point Compare Unit
** Converted from Verilog->SystemVerilog
**
** Conversion by: Gene Hu
*/

// module declaration
module fcmp (
    input logic [31:0] opa, opb,    // Operand A and B, follows IEEE 754
    output logic unordered,         // Asserted when opa or opb is a NAN (not a number)
    output logic altb, blta, aeqb,  // A>B, B>A, A=B
    output logic inf, zero          // Asserted when opa or opb is a INF(infinite), or when opa is a numeric zero
);

    // Local declarations
    wire logic signa, signb;             // Stores sign of a and b
    wire logic [7:0] expa, expb;         // Stores the exponent of a and b
    wire logic [22:0] fracta, fractb;    // Stores the mantissa of a and b

    // flags
    wire logic expa_ff, expb_ff, fracta_00, fractb_00;                  
    wire logic qnan_a, snan_a, qnan_b, snan_b, opa_inf, opb_inf;    
    wire logic qnan, snan, opa_zero, opb_zero;                           // quiet NAN and signaling NAN flags

    wire logic exp_eq, exp_gt, exp_lt;
    wire logic fract_eq, fract_gt, fract_lt;
    wire logic all_zero;

    // splitting opa and opb into sign bit, exponent, and mantissa
    assign {signa, expa, fracta} = opa;
    assign {signb, expb, fractb} = opb;

    // flag exception logic
    assign expa_ff = &expa;
    assign expb_ff = &expb;
        
    assign fracta_00 = !(|fracta);
    assign fractb_00 = !(|fractb);

    assign qnan_a =  fracta[22];
    assign snan_a = !fracta[22] & |fracta[21:0];
    assign qnan_b =  fractb[22];
    assign snan_b = !fractb[22] & |fractb[21:0];

    assign opa_inf = (expa_ff & fracta_00);
    assign opb_inf = (expb_ff & fractb_00);
    assign inf  = opa_inf | opb_inf;

    assign qnan = (expa_ff & qnan_a) | (expb_ff & qnan_b);
    assign snan = (expa_ff & snan_a) | (expb_ff & snan_b);
    assign unordered = qnan | snan;

    assign opa_zero = !(|expa) & fracta_00;
    assign opb_zero = !(|expb) & fractb_00;
    assign zero = opa_zero;

    // Comparison logic
    assign exp_eq = expa == expb;
    assign exp_gt = expa  > expb;
    assign exp_lt = expa  < expb;

    assign fract_eq = fracta == fractb;
    assign fract_gt = fracta  > fractb;
    assign fract_lt = fracta  < fractb;

    assign all_zero = opa_zero & opb_zero;

    always_comb begin
        casez( {qnan, snan, opa_inf, opb_inf, signa, signb, exp_eq, exp_gt, exp_lt, fract_eq, fract_gt, fract_lt, all_zero})
            //13'b??_??_??_???_???_?: {altb, blta, aeqb} = 3'b000;
            13'b1?_??_??_???_???_?: {altb, blta, aeqb} = 3'b000;	// qnan
            13'b?1_??_??_???_???_?: {altb, blta, aeqb} = 3'b000;	// snan

            13'b00_11_00_???_???_?: {altb, blta, aeqb} = 3'b001;	// both op INF comparisson
            13'b00_11_01_???_???_?: {altb, blta, aeqb} = 3'b100;
            13'b00_11_10_???_???_?: {altb, blta, aeqb} = 3'b010;
            13'b00_11_11_???_???_?: {altb, blta, aeqb} = 3'b001;

            13'b00_10_00_???_???_?: {altb, blta, aeqb} = 3'b100;	// opa INF comparisson
            13'b00_10_01_???_???_?: {altb, blta, aeqb} = 3'b100;
            13'b00_10_10_???_???_?: {altb, blta, aeqb} = 3'b010;
            13'b00_10_11_???_???_?: {altb, blta, aeqb} = 3'b010;

            13'b00_01_00_???_???_?: {altb, blta, aeqb} = 3'b010;	// opb INF comparisson
            13'b00_01_01_???_???_?: {altb, blta, aeqb} = 3'b100;
            13'b00_01_10_???_???_?: {altb, blta, aeqb} = 3'b010;
            13'b00_01_11_???_???_?: {altb, blta, aeqb} = 3'b100;

            13'b00_00_10_???_???_0: {altb, blta, aeqb} = 3'b010;	//compare base on sign
            13'b00_00_01_???_???_0: {altb, blta, aeqb} = 3'b100;	//compare base on sign

            13'b00_00_??_???_???_1: {altb, blta, aeqb} = 3'b001;	//compare base on sign both are zero

            13'b00_00_00_010_???_?: {altb, blta, aeqb} = 3'b100;	// cmp exp, equal sign
            13'b00_00_00_001_???_?: {altb, blta, aeqb} = 3'b010;
            13'b00_00_11_010_???_?: {altb, blta, aeqb} = 3'b010;
            13'b00_00_11_001_???_?: {altb, blta, aeqb} = 3'b100;

            13'b00_00_00_100_010_?: {altb, blta, aeqb} = 3'b100;	// compare fractions, equal sign, equal exp
            13'b00_00_00_100_001_?: {altb, blta, aeqb} = 3'b010;
            13'b00_00_11_100_010_?: {altb, blta, aeqb} = 3'b010;
            13'b00_00_11_100_001_?: {altb, blta, aeqb} = 3'b100;

            13'b00_00_00_100_100_?: {altb, blta, aeqb} = 3'b001;
            13'b00_00_11_100_100_?: {altb, blta, aeqb} = 3'b001;

            default: {altb, blta, aeqb} = 3'bxxx;
        endcase
    end
endmodule : fcmp