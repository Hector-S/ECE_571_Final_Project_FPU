`timescale 1ns / 100ps
module fpu(
    input logic clk,
    input logic [1:0] rmode,
    input logic [2:0] fpu_op,
    input logic [31:0] opa, opb,
    output logic [31:0] out,
    output logic inf, snan, qnan,
    output logic ine,
    output logic overflow, underflow,
    output logic zero,
    output logic div_by_zero
);

parameter logic [30:0] INF  = 31'h7f800000,
                       QNAN = 31'h7fc00001,
                       SNAN = 31'h7f800001;

// Local variables
logic [31:0] opa_r, opb_r;      
logic signa, signb;              
logic sign_fasu;                
logic [26:0] fracta, fractb;    
logic [7:0] exp_fasu;          
logic [7:0] exp_r;              
logic [26:0] fract_out_d;        
logic co;                      
logic [27:0] fract_out_q;      
logic [30:0] out_d;        
logic overflow_d, underflow_d;    
logic [1:0] rmode_r1, rmode_r2, rmode_r3;
logic [2:0] fpu_op_r1, fpu_op_r2, fpu_op_r3;
logic mul_inf, div_inf;
logic mul_00, div_00;

// Input Registers


always_ff @(posedge clk) begin
    opa_r <= opa;
    opb_r <= opb;
    rmode_r1 <= rmode;
    rmode_r2 <= rmode_r1;
    rmode_r3 <= rmode_r2;
    fpu_op_r1 <= fpu_op;
    fpu_op_r2 <= fpu_op_r1;
    fpu_op_r3 <= fpu_op_r2;
end

////////////////////////////////////////////////////////////////////////
//
// Exceptions block
//
logic inf_d, ind_d, qnan_d, snan_d, opa_nan, opb_nan;
logic opa_00, opb_00;
logic opa_inf, opb_inf;
logic opa_dn, opb_dn;

except u0(
    .clk(clk),
    .opa(opa_r), .opb(opb_r),
    .inf(inf_d), .ind(ind_d),
    .qnan(qnan_d), .snan(snan_d),
    .opa_nan(opa_nan), .opb_nan(opb_nan),
    .opa_00(opa_00), .opb_00(opb_00),
    .opa_inf(opa_inf), .opb_inf(opb_inf),
    .opa_dn(opa_dn), .opb_dn(opb_dn)
);
////////////////////////////////////////////////////////////////////////
// Pre-Normalize block
logic nan_sign_d, result_zero_sign_d;
logic sign_fasu_r;
logic [7:0] exp_mul;
logic sign_mul;
logic sign_mul_r;
logic [23:0] fracta_mul, fractb_mul;
logic inf_mul;
logic inf_mul_r;
logic [1:0] exp_ovf;
logic [1:0] exp_ovf_r;
logic sign_exe;
logic sign_exe_r;
logic [2:0] underflow_fmul_d;

pre_norm u1(
    .clk(clk),                      // System Clock
    .rmode(rmode_r2),               // Rounding Mode
    .add(!fpu_op_r1[0]),            // Add/Sub Input
    .opa(opa_r), .opb(opb_r),       // Registered OP Inputs
    .opa_nan(opa_nan),              // OpA is a NAN indicator
    .opb_nan(opb_nan),              // OpB is a NAN indicator
    .fracta_out(fracta),            // Equalized and sorted fraction
    .fractb_out(fractb),            // Outputs (Registered)
    .exp_dn_out(exp_fasu),          // Selected exponent output (registered)
    .sign(sign_fasu),               // Encoded output Sign (registered)
    .nan_sign(nan_sign_d),          // Output Sign for NANs (registered)
    .result_zero_sign(result_zero_sign_d), // Output Sign for zero result (registered)
    .fasu_op(fasu_op)               // Actual fasu operation output (registered)
);

always_ff @(posedge clk) begin
    sign_fasu_r <= sign_fasu;
end

pre_norm_fmul u2(
    .clk(clk),
    .fpu_op(fpu_op_r1),
    .opa(opa_r), .opb(opb_r),
    .fracta(fracta_mul),
    .fractb(fractb_mul),
    .exp_out(exp_mul),              // FMUL exponent output (registered)
    .sign(sign_mul),                // FMUL sign output (registered)
    .sign_exe(sign_exe),            // FMUL exception sign output (registered)
    .inf(inf_mul),                  // FMUL inf output (registered)
    .exp_ovf(exp_ovf),              // FMUL exponent overflow output (registered)
    .underflow(underflow_fmul_d)
);

always_ff @(posedge clk) begin
    sign_mul_r <= sign_mul;
    sign_exe_r <= sign_exe;
    inf_mul_r <= inf_mul;
    exp_ovf_r <= exp_ovf;
end
///////////////////////////////////////////// Add/Sub
add_sub27 u3(
    .add(fasu_op),                  
    .opa(fracta),                  
    .opb(fractb),                  
    .sum(fract_out_d),              
    .co(co_d)                    
);
always_ff @(posedge clk) begin
    fract_out_q <= {co_d, fract_out_d};
end
////////////////////////////////////////////////Mul
logic [47:0] prod;

mul_r2 u5(
    .clk(clk),
    .opa(fracta_mul),
    .opb(fractb_mul),
    .prod(prod)
);
// Divide
logic [49:0] quo;
logic [49:0] fdiv_opa;
logic [49:0] remainder;
logic remainder_00;
logic [4:0] div_opa_ldz_d, div_opa_ldz_r1, div_opa_ldz_r2;

always_ff @(fracta_mul) begin
    casex(fracta_mul[22:0])
        23'b1??????????????????????: div_opa_ldz_d = 1;
        23'b01?????????????????????: div_opa_ldz_d = 2;
        23'b001????????????????????: div_opa_ldz_d = 3;
        23'b0001???????????????????: div_opa_ldz_d = 4;
        23'b00001??????????????????: div_opa_ldz_d = 5;
        23'b000001?????????????????: div_opa_ldz_d = 6;
        23'b0000001????????????????: div_opa_ldz_d = 7;
        23'b00000001???????????????: div_opa_ldz_d = 8;
        23'b000000001??????????????: div_opa_ldz_d = 9;
        23'b0000000001?????????????: div_opa_ldz_d = 10;
        23'b00000000001????????????: div_opa_ldz_d = 11;
        23'b000000000001???????????: div_opa_ldz_d = 12;
        23'b0000000000001??????????: div_opa_ldz_d = 13;
        23'b00000000000001?????????: div_opa_ldz_d = 14;
        23'b000000000000001????????: div_opa_ldz_d = 15;
        23'b0000000000000001???????: div_opa_ldz_d = 16;
        23'b00000000000000001??????: div_opa_ldz_d = 17;
        23'b000000000000000001?????: div_opa_ldz_d = 18;
        23'b0000000000000000001????: div_opa_ldz_d = 19;
        23'b00000000000000000001???: div_opa_ldz_d = 20;
        23'b000000000000000000001??: div_opa_ldz_d = 21;
        23'b0000000000000000000001?: div_opa_ldz_d = 22;
        23'b0000000000000000000000?: div_opa_ldz_d = 23;
    endcase
end

assign fdiv_opa = !(|opa_r[30:23]) ? {(fracta_mul << div_opa_ldz_d), 26'h0} : {fracta_mul, 26'h0};

div_r2 u6(
    .clk(clk),
    .opa(fdiv_opa),
    .opb(fractb_mul),
    .quo(quo),
    .rem(remainder)
);

assign remainder_00 = !(|remainder);

always_ff @(posedge clk) begin
    div_opa_ldz_r1 <= div_opa_ldz_d;
    div_opa_ldz_r2 <= div_opa_ldz_r1;
end
////////////////////////////////////////////////////////////////////////
// Normalize Result
logic ine_d;
logic [47:0] fract_denorm;
logic [47:0] fract_div;
logic sign_d;
logic sign;
logic [30:0] opa_r1;
logic [47:0] fract_i2f;
logic opas_r1, opas_r2;
logic f2i_out_sign;

always_ff @(posedge clk) begin  // Exponent must be once cycle delayed
    case(fpu_op_r2)
        0, 1: exp_r <= exp_fasu;
        2, 3: exp_r <= exp_mul;
        4:   exp_r <= 0;
        5:   exp_r <= opa_r1[30:23];
        default: exp_r <= 'x;
    endcase
end
assign fract_div = (opb_dn ? quo[49:2] : {quo[26:0], 21'h0});
always_ff @(posedge clk) begin
    opa_r1 <= opa_r[30:0];
    fract_i2f <= (fpu_op_r2 == 5) ?
        (sign_d ? 1 - {24'h00, (|opa_r1[30:23]), opa_r1[22:0]} - 1 : {24'h0, (|opa_r1[30:23]), opa_r1[22:0]}) :
        (sign_d ? 1 - {opa_r1, 17'h01} : {opa_r1, 17'h0});
end

always_comb begin
    case(fpu_op_r3)
        0, 1: fract_denorm = {fract_out_q, 20'h0};
        2:    fract_denorm = prod;
        3:    fract_denorm = fract_div;
        4, 5: fract_denorm = fract_i2f;
        default: fract_denorm = 'x;
    endcase
end
always_ff @(posedge clk) begin
    opas_r1 <= opa_r[31];
    opas_r2 <= opas_r1;
end
assign sign_d = fpu_op_r2[1] ? sign_mul : sign_fasu;
always_ff @(posedge clk) begin
    sign <= (rmode_r2 == 2'h3) ? !sign_d : sign_d;
end

post_norm u4(
    .clk(clk),                     // System Clock
    .fpu_op(fpu_op_r3),            // Floating Point Operation
    .opas(opas_r2),                // OPA Sign
    .sign(sign),                   // Sign of the result
    .rmode(rmode_r3),              // Rounding mode
    .fract_in(fract_denorm),       // Fraction Input
    .exp_ovf(exp_ovf_r),           // Exponent Overflow
    .exp_in(exp_r),                // Exponent Input
    .opa_dn(opa_dn),               // Operand A Denormalized
    .opb_dn(opb_dn),               // Operand A Denormalized
    .rem_00(remainder_00),         // Divide Remainder is zero
    .div_opa_ldz(div_opa_ldz_r2),  // Divide opa leading zeros count
    .output_zero(mul_00 | div_00), // Force output to Zero
    .out(out_d),                   // Normalized output (un-registered)
    .ine(ine_d),                   // Result Inexact output (un-registered)
    .overflow(overflow_d),         // Overflow output (un-registered)
    .underflow(underflow_d),       // Underflow output (un-registered)
    .f2i_out_sign(f2i_out_sign)    // F2I Output Sign
);
///////////////////////////////////////// FPU Outputs

logic    fasu_op_r1, fasu_op_r2;
logic [30:0] out_fixed;
logic    output_zero_fasu;
logic    output_zero_fdiv;
logic    output_zero_fmul;
logic    inf_mul2;
logic    overflow_fasu;
logic    overflow_fmul;
logic    overflow_fdiv;
logic    inf_fmul;
logic    sign_mul_final;
logic    out_d_00;
logic    sign_div_final;
logic    ine_mul, ine_mula, ine_div, ine_fasu;
logic    underflow_fasu, underflow_fmul, underflow_fdiv;
logic    underflow_fmul1;
logic [2:0] underflow_fmul_r;
logic    opa_nan_r;
// Sequential always blocks using 'always_ff' in SystemVerilog
always_ff @(posedge clk) begin
    fasu_op_r1 <= fasu_op;
    fasu_op_r2 <= fasu_op_r1;
    inf_mul2 <= (exp_mul == 8'hff);
end
// Force pre-set values for non-numerical output
assign mul_inf = (fpu_op_r3 == 3'b010) & (inf_mul_r | inf_mul2) & (rmode_r3 == 2'h0);
assign div_inf = (fpu_op_r3 == 3'b011) & (opb_00 | opa_inf);
assign mul_00 = (fpu_op_r3 == 3'b010) & (opa_00 | opb_00);
assign div_00 = (fpu_op_r3 == 3'b011) & (opa_00 | opb_inf);
// Assigning out_fixed based on various conditions
assign out_fixed = (   (qnan_d | snan_d) |
                       (ind_d & !fasu_op_r2) |
                       ((fpu_op_r3 == 3'b011) & opb_00 & opa_00) |
                       (((opa_inf & opb_00) | (opb_inf & opa_00)) & fpu_op_r3 == 3'b010)
                   )  ? QNAN : INF;
// Sequential always block using 'always_ff' in SystemVerilog
always_ff @(posedge clk) begin
    out[30:0] <= (mul_inf | div_inf | (inf_d & (fpu_op_r3 != 3'b011) & (fpu_op_r3 != 3'b101)) | snan_d | qnan_d) & (fpu_op_r3 != 3'b100) ? out_fixed : out_d;
end
////////////////////////////////////////////////////////////////////////////used always_com instead of assign
always_comb begin
// Continuous assignment for out_d_00
out_d_00 = !(|out_d);
// Calculating final sign for multiplication
sign_mul_final = (sign_exe_r & ((opa_00 & opb_inf) | (opb_00 & opa_inf))) ? !sign_mul_r : sign_mul_r;
// Calculating final sign for division
sign_div_final = (sign_exe_r & (opa_inf & opb_inf)) ? !sign_mul_r : sign_mul_r | (opa_00 & opb_00);
end
// Sequential always block for the output sign bit (out[31])
always_ff @(posedge clk) begin
    out[31] <= (fpu_op_r3 == 3'b101 && out_d_00) ? (f2i_out_sign & !(qnan_d | snan_d)) :
               (fpu_op_r3 == 3'b010 && !(snan_d | qnan_d)) ? sign_mul_final :
               (fpu_op_r3 == 3'b011 && !(snan_d | qnan_d)) ? sign_div_final :
               (snan_d | qnan_d | ind_d) ? nan_sign_d :
               output_zero_fasu ? result_zero_sign_d :
               sign_fasu_r;
end
/////////////////////////////////////////////////////////////////////////////////used always_com instead of assign
always_comb begin
// Exception Outputs (Continuous assignments)
ine_mula = ((inf_mul_r | inf_mul2 | opa_inf | opb_inf) & (rmode_r3 == 2'h1) &
                   !((opa_inf & opb_00) | (opb_inf & opa_00)) & fpu_op_r3[1]);

ine_mul = (ine_mula | ine_d | inf_fmul | out_d_00 | overflow_d | underflow_d) &
                 !opa_00 & !opb_00 & !(snan_d | qnan_d | inf_d);

ine_div = (ine_d | overflow_d | underflow_d) & !(opb_00 | snan_d | qnan_d | inf_d);

ine_fasu = (ine_d | overflow_d | underflow_d) & !(snan_d | qnan_d | inf_d);
end
// Sequential always block for exception flag (ine)
always_ff @(posedge clk) begin
    ine <= fpu_op_r3[2] ? ine_d :
           !fpu_op_r3[1] ? ine_fasu :
           fpu_op_r3[0] ? ine_div : ine_mul;
end
/////////////////////////////////////////////////////////////////////////////////used always_com instead of assign
always_comb begin
// Exception condition for overflow
overflow_fasu = overflow_d & !(snan_d | qnan_d | inf_d);
overflow_fmul = !inf_d & (inf_mul_r | inf_mul2 | overflow_d) & !(snan_d | qnan_d);
overflow_fdiv = overflow_d & !(opb_00 | inf_d | snan_d | qnan_d);
end
// Sequential always block for overflow condition (using always_ff)
always_ff @(posedge clk) begin
    overflow <= (fpu_op_r3[2]) ? 0 :
                (!fpu_op_r3[1]) ? overflow_fasu :
                (fpu_op_r3[0]) ? overflow_fdiv : overflow_fmul;
    underflow_fmul_r <= underflow_fmul_d;
end
// Continuous assignment for underflow calculation
assign underflow_fmul1 = underflow_fmul_r[0] |
                          (underflow_fmul_r[1] & underflow_d) |
                          ((opa_dn | opb_dn) & out_d_00 & (prod != 0) & sign) |
                          (underflow_fmul_r[2] & ((out_d[30:23] == 0) | (out_d[22:0] == 0)));
/////////////////////////////////////////////////////////////////////////////////used always_com instead of assign
always_comb begin
// Continuous assignments for underflow checks in FPU operations
underflow_fasu = underflow_d & !(inf_d | snan_d | qnan_d);
underflow_fmul = underflow_fmul1 & !(snan_d | qnan_d | inf_mul_r);
underflow_fdiv = underflow_fasu & !opb_00;
end
// Sequential always block for underflow condition (using always_ff)
always_ff @(posedge clk) begin
    underflow <= (fpu_op_r3[2]) ? 0 :
                 (!fpu_op_r3[1]) ? underflow_fasu :
                 (fpu_op_r3[0]) ? underflow_fdiv : underflow_fmul;
    snan <= snan_d;
end
//////////////////////////////////////////////////////////////////////////////////////
// Synopsys directive to disable synthesis for certain wires
// This is typically used in verification or simulation environments to handle non-synthesizable constructs
// The following wires are just declared, and do not affect synthesis
`ifdef SYNTHESIS
/////////////////////////////////////////////////////////////////////////////////////////// wire to logic
logic mul_uf_del;
logic uf2_del, ufb2_del, ufc2_del, underflow_d_del;
logic co_del;
logic [30:0] out_d_del;
logic ov_fasu_del, ov_fmul_del;
logic [2:0] fop;
logic [4:0] ldza_del;
logic [49:0] quo_del;

// Delay elements for various signals (using always_ff for sequential behavior)
delay1 #0 ud000(clk, underflow_fmul1, mul_uf_del);
delay1 #0 ud001(clk, underflow_fmul_r[0], uf2_del);
delay1 #0 ud002(clk, underflow_fmul_r[1], ufb2_del);
delay1 #0 ud003(clk, underflow_d, underflow_d_del);
delay1 #0 ud004(clk, test.u0.u4.exp_out1_co, co_del);
delay1 #0 ud005(clk, underflow_fmul_r[2], ufc2_del);
delay1 #30 ud006(clk, out_d, out_d_del);

delay1 #0 ud007(clk, overflow_fasu, ov_fasu_del);
delay1 #0 ud008(clk, overflow_fmul, ov_fmul_del);

delay1 #2 ud009(clk, fpu_op_r3, fop);

delay3 #4 ud010(clk, div_opa_ldz_d, ldza_del);

delay1 #49 ud012(clk, quo, quo_del);

// Displaying debug information on error event (used for simulation purposes)
always_ff @(test.error_event) begin
    // Delay for time unit precision
    $display("muf: %b uf0: %b uf1: %b uf2: %b, tx0: %b, co: %b, out_d: %h (%h %h), ov_fasu: %b, ov_fmul: %b, fop: %h",
             mul_uf_del, uf2_del, ufb2_del, ufc2_del, underflow_d_del, co_del, out_d_del, out_d_del[30:23], out_d_del[22:0],
             ov_fasu_del, ov_fmul_del, fop );
    $display("ldza: %h, quo: %b",
             ldza_del, quo_del);
end
`endif

// Status Outputs

// Assigning qnan based on multiple conditions
always_ff @(posedge clk) begin
    qnan <= (fpu_op_r3[2]) ? 0 : (
                     snan_d | qnan_d | (ind_d & !fasu_op_r2) |
                     (opa_00 & opb_00 & fpu_op_r3 == 3'b011) |
                     (((opa_inf & opb_00) | (opb_inf & opa_00)) & fpu_op_r3 == 3'b010)
                    );
end

// Calculating infinity for floating point multiplication
assign inf_fmul = (((inf_mul_r | inf_mul2) & (rmode_r3 == 2'h0)) | opa_inf | opb_inf) &
                  !((opa_inf & opb_00) | (opb_inf & opa_00)) &
                  (fpu_op_r3 == 3'b010);

// Assigning infinity condition for the result
always_ff @(posedge clk) begin
    inf <= (fpu_op_r3[2]) ? 0 :
           (!(qnan_d | snan_d) & (
               ((&out_d[30:23]) & !(|out_d[22:0]) & !(opb_00 & fpu_op_r3 == 3'b011)) |
               (inf_d & !(ind_d & !fasu_op_r2) & !fpu_op_r3[1]) |
               inf_fmul |
               (!opa_00 & opb_00 & fpu_op_r3 == 3'b011) |
               (fpu_op_r3 == 3'b011 & opa_inf & !opb_inf)
           ));
end
always_comb begin
// Zero output calculations based on floating-point operations
output_zero_fasu = out_d_00 & !(inf_d | snan_d | qnan_d);
output_zero_fdiv = (div_00 | (out_d_00 & !opb_00)) & !(opa_inf & opb_inf) &
                          !(opa_00 & opb_00) & !(qnan_d | snan_d);
output_zero_fmul = (out_d_00 | opa_00 | opb_00) &
                          !(inf_mul_r | inf_mul2 | opa_inf | opb_inf | snan_d | qnan_d) &
                          !(opa_inf & opb_00) & !(opb_inf & opa_00);
end
// Sequential block to assign zero for output based on floating-point operation type
always_ff @(posedge clk) begin
    zero <= (fpu_op_r3 == 3'b101) ? out_d_00 & !(snan_d | qnan_d) :
            (fpu_op_r3 == 3'b011) ? output_zero_fdiv :
            (fpu_op_r3 == 3'b010) ? output_zero_fmul :
                                    output_zero_fasu;
end

// Sequential block for opa_nan_r signal
always_ff @(posedge clk) begin
    opa_nan_r <= !opa_nan & (fpu_op_r2 == 3'b011);
// Sequential block for division by zero detection
div_by_zero <= opa_nan_r & !opa_00 & !opa_inf & opb_00;
end

endmodule
