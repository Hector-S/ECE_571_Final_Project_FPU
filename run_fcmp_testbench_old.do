puts "Creating new 'ECE571_FCMP_OLD' project..."
project new . ECE571_FCMP ECE571_FCMP_OLD
project addfile RTL_OLD/fcmp/verilog/fcmp.v
project addfile RTL_OLD/fcmp/test_bench/test_top.v
project compileall
vsim -voptargs=+acc ECE571_FCMP_OLD.test
transcript file "SIM/ece571_project_fcmp_original_transcript.txt"
run -all
