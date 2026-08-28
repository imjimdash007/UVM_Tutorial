

call xvlog -sv -f adder_4_bit_compile_list.f -L uvm -define "NO_OF_TRANSACTIONS=200";
call xelab adder_4_bit_tb_top -relax -s top -timescale 1ns/1ps -debug all;
call xsim top -testplusarg "UVM_TESTNAME=adder_4_bit_basic_test" -testplusarg "UVM_VERBOSITY=UVM_LOW"  --gui 