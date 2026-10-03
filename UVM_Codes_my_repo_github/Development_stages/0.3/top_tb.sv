`include "m_if.sv"
`include "env.sv"
`include "counter.v"

`include "uvm_macros.svh"
import uvm_pkg::*;

module top_tb;
  logic clk;

  m_if m_if_inst(.clk(clk));
  
  counter counter_inst(
    .clk(clk), 
    .rst(m_if_inst.rst),
    .count(m_if_inst.count) 
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    uvm_config_db#(virtual m_if)::set(null, "*", "vif", m_if_inst);
    uvm_pkg::uvm_top.enable_print_topology = 1;
    run_test("my_env");
  end
endmodule
