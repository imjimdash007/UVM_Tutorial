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
    uvm_config_db#(virtual m_if)::set(null, "*", "vif", m_if_inst);
    
    // Start the testbench (UVM will automatically instantiate "my_driver" as "uvm_test_top")
    run_test("my_driver");
  end
  
  bind counter counter_assertions assertion_inst (
    .clk(clk),
    .rst(rst),
    .count(count)
);
endmodule



//qverilog -sv top_tb.sv counter_assertions.sv -R -gui -voptargs="+acc" -assertdebug -do "add log -r /*; run -all"

