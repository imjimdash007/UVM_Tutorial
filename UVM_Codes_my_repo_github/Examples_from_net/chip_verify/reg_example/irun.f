-incdir $UVM_HOME
-incdir ./tb
-input cmd.tcl +access+rw
+UVM_NO_RELNOTES
-uvm -sv
./rtl/design.v
./tb/my_env.sv
./tb/test_lib.sv
./tb/tb_top.sv