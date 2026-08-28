set test [pwd]
cd ..
set test_path [pwd]
create_project adder_proj -part xc7vx485tffg1157-1 -force
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_defines.svh
add_files -norecurse ${test_path}/verif/env/ref_model/adder_4_bit_ref_model.sv
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_agent_pkg.sv
add_files -norecurse ${test_path}/verif/tb/src/adder_4_bit_tb_top.sv
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_agent.sv
add_files -norecurse ${test_path}/verif/env/top/adder_4_bit_env_pkg.sv
add_files -norecurse ${test_path}/verif/tests/src/adder_4_bit_test_list.sv
add_files -norecurse ${test_path}/verif/env/top/adder_4_bit_scoreboard.sv
add_files -norecurse ${test_path}/verif/tests/src/adder_4_bit_basic_test.sv
add_files -norecurse ${test_path}/verif/env/top/adder_4_bit_env.sv 
add_files -norecurse ${test_path}/src/design/half_adder.sv 
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_monitor.sv
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_transaction.sv
add_files -norecurse ${test_path}/verif/env/ref_model/adder_4_bit_ref_model_pkg.sv 
add_files -norecurse ${test_path}/verif/tests/sequence_lib/src/adder_4_bit_basic_seq.sv
add_files -norecurse ${test_path}/src/design/full_adder.sv 
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_sequencer.sv
add_files -norecurse ${test_path}/verif/env/top/adder_4_bit_coverage.sv 
add_files -norecurse ${test_path}/src/design/adder_4_bit.sv
add_files -norecurse ${test_path}/verif/env/agents/adder_4_bit_agent/adder_4_bit_driver.sv
add_files -norecurse ${test_path}/verif/tb/src/adder_4_bit_interface.sv
add_files -norecurse ${test_path}/verif/tests/sequence_lib/src/adder_4_bit_seq_list.sv
set_property top adder_4_bit_tb_top [current_fileset]
cd run
exec xvlog -sv -f adder_4_bit_compile_list.f -L uvm -define NO_OF_TRANSACTIONS=20; 
exec xelab adder_4_bit_tb_top -relax -s top -timescale 1ns/1ps -debug all;  
exec xsim top -testplusarg UVM_TESTNAME=adder_4_bit_basic_test -testplusarg UVM_VERBOSITY=UVM_LOW --gui  

