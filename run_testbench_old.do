puts "Creating new 'ECE571_FP' project..."
project new . ECE571_FP_OLD ECE571_FP_OLD
project addfile RTL_OLD/verilog/except.v
project addfile RTL_OLD/verilog/fpu.v
project addfile RTL_OLD/verilog/post_norm.v
project addfile RTL_OLD/verilog/pre_norm.v
project addfile RTL_OLD/verilog/pre_norm_fmul.v
project addfile RTL_OLD/verilog/primitives.v
project addfile RTL_OLD/test_bench/test_top.v
project compileall
vsim -voptargs=+acc ECE571_FP_OLD.test
transcript file "SIM/test_top_original_transcript.txt"
run -all
