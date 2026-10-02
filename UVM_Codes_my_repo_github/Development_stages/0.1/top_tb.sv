`include "m_if.sv"
`include "monitor.sv"
`include "counter.v"
`include "uvm_macros.svh"
import uvm_pkg::*;

module top_tb;
  // Clock signal (Removed unused local rst logic)
  logic clk;
  logic rst;
  bit	disable_monitor = 0;
  assign m_if_inst.rst = rst; 

  // Instantiate the interface
  m_if m_if_inst(.clk(clk));
  
  // Instantiate the counter DUT
  counter counter_inst(.clk(clk), .rst(m_if_inst.rst),.count(m_if_inst.count));
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end
  initial begin
     rst = 1;		       
     `uvm_info("TOP_TB", "Starting the testbench", UVM_LOW)
     // UVM 1.1d alternative to raise objection globally from outside a component
     uvm_pkg::uvm_test_done.raise_objection(null, "Holding simulation alive in top_tb");
     #10; 
     rst = 0;		 
     #100;
     // Drop the objection to let the run_phase wrap up and proceed to extract_phase
     uvm_pkg::uvm_test_done.drop_objection(null, "Releasing simulation in top_tb");
  end
  // Connect the interface and hand off execution to the factory
  initial begin
    // Set the config db context globally
    uvm_config_db#(virtual m_if)::set(null, "*", "vif", m_if_inst); //will change this for hiearchical later uvm_test_top.env.in_agent. <someday MTLR ! >
    uvm_config_db#(bit )::set(null, "*", "disable_monitor", 0);  // disable the monitor in in_put side <future> enable the monitor for output hierarchy 
    uvm_pkg::uvm_top.enable_print_topology = 1;
    // Start the testbench (UVM will automatically instantiate "my_driver" as "uvm_test_top")
    run_test("my_monitor");
  end
endmodule

//qverilog -sv top_tb.sv -R -gui -voptargs="+acc" -do "add log -r /*; add wave -position insertpoint sim:/top_tb/counter_inst/clk sim:/top_tb/counter_inst/rst sim:/top_tb/counter_inst/count; run -all"

