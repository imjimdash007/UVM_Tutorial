vlog -sv top_tb.sv
vsim -voptargs="+acc" top_tb -do \
"log -r /*; add wave -position insertpoint sim:/top_tb/dut/clk sim:/top_tb/dut/rst sim:/top_tb/dut/load sim:/top_tb/dut/count_in sim:/top_tb/dut/count_out; run 30 ns"

