vlog -work work -vopt -sv Hello_World.sv
vsim -c  "+define+UVM_NO_RELNOTES" work.top -do "run -a;quit -f"
