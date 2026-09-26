vlog -work work -vopt -sv uvm_barrier.sv
vsim -c  "+define+UVM_NO_RELNOTES" work.uvm_barrier_ex -do "run -a;quit -f"
