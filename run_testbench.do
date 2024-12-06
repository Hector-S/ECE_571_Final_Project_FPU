puts "Creating new 'ECE571_FP' project..."
project new . ECE571_FP ECE571_FP
project addfile RTL/verilog/except.sv
project addfile RTL/verilog/fpu.sv
project addfile RTL/verilog/post_norm.sv
project addfile RTL/verilog/pre_norm.sv
project addfile RTL/verilog/pre_norm_fmul.sv
project addfile RTL/verilog/primitives.sv
project addfile RTL/test_bench/test_top.sv
project compileall
vsim -voptargs=+acc ECE571_FP.test
transcript file "SIM/test_top_sv_transcript.txt"
run -all
