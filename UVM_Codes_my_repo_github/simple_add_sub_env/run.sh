vlog -work work -sv adder_sub_env.sv
vsim  "+define+UVM_NO_RELNOTES" work.top -voptargs="+acc" 
