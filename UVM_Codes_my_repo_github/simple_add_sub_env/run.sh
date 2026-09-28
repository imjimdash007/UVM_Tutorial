vlog -work work -sv adder_sub_env.sv 
vsim  "+define+UVM_NO_RELNOTES" work.top -voptargs="+acc"  -do "add wave -position insertpoint  \
sim:/top/dut/clk \
sim:/top/dut/a0 \
sim:/top/dut/b0 \
sim:/top/dut/doAdd0 \
sim:/top/dut/result0"
