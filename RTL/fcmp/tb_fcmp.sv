/* TB FCMP                                        
** Test bench for Single precision Floating Point Compare Unit
** Converted from Verilog->SystemVerilog
**
** Conversion by: Gene Hu
*/

module tb_fcmp;
    // Declarations for ports and testbench
    logic		        clk;
    logic	    [31:0]	opa;
    logic	    [31:0]	opb;
    wire logic	[3:0]	sum;
    wire logic		    inf, snan, qnan;
    wire logic		    div_by_zero;
    wire logic		    altb, blta, aeqb;
    wire logic		    unordered;

    logic	    [3:0]	exp;
    logic	    [31:0]	opa1;
    logic	    [31:0]	opb1;
    logic	    [2:0]	fpu_op;
    logic	    [3:0]	rmode;
    logic	    	    start;
    logic	    [75:0]	tmem[0:500000];
    logic	    [75:0]	tmp;
    logic	    [7:0]	oper;
    logic	    [7:0]	exc;
    integer		        i;
    wire logic		    ine;
    logic		        match;
    wire logic		    overflow, underflow;
    wire logic		    zero;
    logic		        exc_err;
    logic		        m0, m1, m2;
    logic	    [1:0]	fpu_rmode;
    logic	    [3:0]	test_rmode;
    logic	    [4:0]	test_sel;
    logic		        fp_fasu;
    logic		        fp_mul;
    logic		        fp_div;
    logic		        fp_combo;
    logic		        fp_i2f;
    logic		        fp_0fcmp;
    logic		        test_exc;
    logic		        show_prog;
    event		        error_event;

    integer		        error = 0;
	integer				vcount = 0;

	// instantiation 
    fcmp u0(opa, opb, unordered, altb, blta, aeqb, inf, zero );
	
    // clock pulse
    always #50 clk = ~clk;
    
    // initializing values, greeting message
    initial begin
        $display ("\n\nFloating Point Compare Version 1.0\nConverted to SystemVerilog for ECE571\n");
        clk = 0;
        start = 0;
        show_prog = 0;

        test_exc = 1;
        test_sel   = 5'b11111;	// There are 5 different tests, a 1 indicate that test is being used this run
    end

	// Loading in test vector hex code from test_vectors
    initial @(posedge clk) begin
        $display("\n\nTesting FP CMP Unit\n");

        if(test_sel[0]) begin
            $display("\nRunning Pat 0 Test ...\n");
            $readmemh ("RTL/test_vectors/fcmp/fcmp_pat0.hex", tmem);
            run_test;
        end
        
        if(test_sel[1]) begin
            $display("\nRunning Pat 1 Test ...\n");
            $readmemh ("RTL/test_vectors/fcmp/fcmp_pat1.hex", tmem);
            run_test;
        end
        
        if(test_sel[2]) begin
            $display("\nRunning Pat 2 Test ...\n");
            $readmemh ("RTL/test_vectors/fcmp/fcmp_pat2.hex", tmem);
            run_test;
        end
        
        if(test_sel[3]) begin
            $display("\nRunning Random Lg. Num Test ...\n");
            $readmemh ("RTL/test_vectors/fcmp/fcmp_lg.hex", tmem);
            run_test;
        end
        
        if(test_sel[4]) begin
            $display("\nRunning Random Sm. Num Test ...\n");
            $readmemh ("RTL/test_vectors/fcmp/fcmp_sm.hex", tmem);
            run_test;
        end

        // waiting clk cycles before ending test
        repeat (8)	@(posedge clk);
            
        $display("\n\n");

        $display("\n\nAll test Done !\n\n");
        $display("Run %0d vectors, found %0d errors.\n\n",vcount, error);

        $stop;
    end

	// task used by each test to test the loaded hex inside tmem
    task automatic run_test;
        @(posedge clk);
        #1;
        opa = 32'h0;
        opb = 32'hx;

        @(posedge clk);
        #1;

        i=0;
        while( |opa !== 1'bx ) begin
            @(posedge clk);
            #1;
            start = 1;
            tmp   = tmem[i];

            exc   = tmp[75:68];
            opa   = tmp[67:36];
            opb   = tmp[35:04];

            exp   = exc==0 ? tmp[03:00] : 0;

            if(show_prog)	$write("Vector: %d\015",i);

            i= i+1;
        end
        start = 0;

        @(posedge clk);
        #1;
        opa = 32'hx;
        opb = 32'hx;
        fpu_rmode = 2'hx;

        @(posedge clk);
        #1;

        for(i=0;i<500000;i=i+1)	begin	// Clear Memory
            tmem[i] = 76'hxxxxxxxxxxxxxxxxx;
        end
    endtask
	
	// Error checking
	assign m0 = ( (|sum) !== 1'b1) & ( (|sum) !== 1'b0);		// result unknown (ERROR)
	assign match = (exp === sum) ;								// results are equal
    always_ff @(posedge clk) begin
        //	Floating Point Exceptions ( exc4 )
        //	-------------------------
        //	float_flag_invalid   =  1,
        //	float_flag_divbyzero =  4,
        //	float_flag_overflow  =  8,
        //	float_flag_underflow = 16,
        //	float_flag_inexact   = 32

        exc_err<=0;

        if(test_exc) begin
            if(exc[5]) begin
                exc_err<=1;
                $display("\nERROR: INE Exception: Expected: 0, Got 1\n");
            end

            if(exc[3]) begin
                exc_err<=1;
                $display("\nERROR: Overflow Exception: Expected: 0, Got 1\n");
            end

            if(exc[4]) begin
                exc_err<=1;
                $display("\nERROR: Underflow Exception: Expected: 0, Got 1\n");
            end
        
            if(zero !== !(|opa[30:0])) begin
                exc_err<=1;
                $display("\nERROR: Zero Detection Failed. ZERO: %h, Sum: %h\n", zero, opa);
            end
        

            if(inf !== (((opa[30:23] == 8'hff) & ((|opa[22:0]) == 1'b0)) | ((opb[30:23] == 8'hff) & ((|opb[22:0]) == 1'b0))) ) begin
                exc_err<=1;
                $display("\nERROR: INF Detection Failed. INF: %h, Sum: %h\n", inf, sum);
            end

            if(unordered !== ( ( &opa[30:23] & |opa[22:0]) | ( &opb[30:23] & |opb[22:0]) ) ) begin
                exc_err<=1;
                $display("\nERROR: UNORDERED Detection Failed. SNAN: %h, OpA: %h, OpB: %h\n", snan, opa, opb);
            end

        end

        if( (exc_err | !match | m0) & start ) begin
            $display("\n%t: ERROR: output mismatch. Expected %h, Got %h (%h|%h|%h)", $time, exp, sum, opa, opb, exp);
			$display("exc_err: %0d, match: %0d, m0: %0d", exc_err, match, m0);
            $write("opa:\t");	disp_fp(opa);
            $write("opb:\t");	disp_fp(opb);
            $display("EXP:\t%b",exp);
            $display("GOT:\t%b",sum);
            $display("\n");

            error <= error + 1;
        end

        if(start)	vcount <= vcount + 1;

        if(error > 10) begin
            $display("\n\nFound to many errors, aborting ...\n\n");
            $display("Run %0d vecors, found %0d errors.\n\n",vcount, error);
            $stop;
        end
    end

    assign sum = {1'b0, altb, blta, aeqb};
	
	// used for displaying the floating point value
    task disp_fp (
        input logic [31:0] fp
    );
        logic 	[63:0]	x;
        logic	[7:0]	exp;

        exp = fp[30:23];

        if(exp==8'h7f) begin
            $write("(%h %h ( 00 ) %h) ",fp[31], exp, fp[22:0]);
        end
        else begin
            if(exp>8'h7f)	$write("(%h %h (+%d ) %h) ",fp[31], exp, exp-8'h7f, fp[22:0]);
            else		    $write("(%h %h (-%d ) %h) ",fp[31], exp, 8'h7f-exp, fp[22:0]);
        end


        x[51:0] = {fp[22:0], 29'h0};
        x[63] = fp[31];
        x[62] = fp[30];
        x[61:59] = {fp[29], fp[29], fp[29]};
        x[58:52] = fp[29:23];

        $display("\t%f",$bitstoreal(x));
    endtask
endmodule : tb_fcmp