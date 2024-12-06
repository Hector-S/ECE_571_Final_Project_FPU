puts "Creating new 'ECE571_FCMP' project..."
project new . ECE571_FCMP ECE571_FCMP
project addfile RTL/fcmp/fcmp_conversion.sv
project addfile RTL/fcmp/tb_fcmp.sv
project compileall
vsim -voptargs=+acc ECE571_FCMP.tb_fcmp
transcript file "SIM/ece571_project_fcmp_sv_transcript.txt"
run -all
