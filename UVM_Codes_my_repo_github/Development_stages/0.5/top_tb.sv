`include "uvm_macros.svh"
import uvm_pkg::*;

`include "m_if.sv"
`include "counter.v"
`include "driver.sv"

module top_tb;
   bit clk; 

   // 1. Instantiate both interfaces and pass the clock
   m_if in_vif(clk);  
   m_if out_vif(clk); 

   // Clock generator (100MHz / 10ns period)
   initial begin
      clk = 0;
      forever #5 clk = ~clk;
   end 

   // 2. Connect the DUT ports to the respective interfaces
   counter dut (
      .clk      (clk),
      .rst      (in_vif.rst),       // Input driven by input interface
      .load     (in_vif.load),      // Input driven by input interface
      .count_in (in_vif.count_in),  // Input driven by input interface
      .count_out(out_vif.count_out) // Output monitored by output interface
   );

   // 4. UVM Configuration Database Registration
   initial begin
      uvm_config_db#(virtual m_if)::set(null, "*", "in_vif", in_vif);
      uvm_config_db#(virtual m_if)::set(null, "*", "out_vif", out_vif);
      uvm_pkg::uvm_top.enable_print_topology = 1;
      // Start the UVM Test
      run_test("my_driver");
   end

endmodule 
