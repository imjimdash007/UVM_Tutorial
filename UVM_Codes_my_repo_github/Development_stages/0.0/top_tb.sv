`include "m_if.sv"
`include "driver.sv"
`include "counter.v"

`include "uvm_macros.svh"
import uvm_pkg::*;

module top_tb;

  // Clock signal (Removed unused local rst logic)
  logic clk;

  // Instantiate the interface
  m_if m_if_inst(.clk(clk));
  
  // Instantiate the counter DUT
  counter counter_inst(.clk(clk), .rst(m_if_inst.rst));

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  initial begin
    `uvm_info("TOP_TB", "Starting the testbench", UVM_LOW)
  end

  // Connect the interface and hand off execution to the factory
  initial begin
    // Set the config db context globally
    uvm_config_db#(virtual m_if)::set(null, "*", "vif", m_if_inst); //will change this for hiearchical later uvm_test_top.env.in_agent. <someday MTLR ! >  
    uvm_pkg::uvm_top.enable_print_topology = 1;
    // Start the testbench (UVM will automatically instantiate "my_driver" as "uvm_test_top")
    run_test("my_driver");
  end
endmodule

//qverilog -sv top_tb.sv -R -gui -voptargs="+acc" -do "add log -r /*; add wave -position insertpoint sim:/top_tb/counter_inst/clk sim:/top_tb/counter_inst/rst sim:/top_tb/counter_inst/count; run -all"

