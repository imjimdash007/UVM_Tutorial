//Added a new interface for SB/Monitor only
`define hier top_tb    //for the hierarchy

import uvm_pkg::*;
`include "uvm_macros.svh"

interface add_sub_dummy_if(
  input bit clk,
  input [8:0] result
);
endinterface: add_sub_dummy_if

//--------------------------------------------------------------
// environment env
//--------------------------------------------------------------
class env extends uvm_env;
   `uvm_component_utils(env)

  virtual add_sub_dummy_if m_en_if;   //Note the virtual in front of the interface

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void connect_phase(uvm_phase phase);
    `uvm_info("LABEL", "Started connect phase.", UVM_LOW);
    // Get the interface from the resource database.
    assert(uvm_config_db#(virtual add_sub_dummy_if)::get(this,get_full_name(), "add_sub_dummy_if", m_en_if)); //Connected
    `uvm_info("LABEL", "Finished connect phase.", UVM_LOW);
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
    `uvm_info("LABEL", "Started run phase.", UVM_LOW);
    begin
    @(m_en_if.clk);
       force top_tb.dut.a0 = 8'h2;  //Whatever you want to force 
       force top_tb.dut.b0 = 8'h3;
       force top_tb.dut.doAdd0 = 'b1;
      repeat(3) @(m_en_if.clk);  //waiting for the clk (Hint: it can be some deep signal if you have assign the same from the design )
      `uvm_info("RESULT     TB", $sformatf("%0d + %0d = %0d", 2, 3, m_en_if.result), UVM_LOW);
    end
    `uvm_info("LABEL", "Finished run phase.", UVM_LOW);
   #2000;
   phase.drop_objection(this);
  endtask: run_phase
endclass


module TB_parallel;
  add_sub_dummy_if m_if();
  env      environment;
  assign   m_if.clk =  `hier.dut.clk;
  assign   m_if.result = `hier.dut.result0;
 
  initial begin
    // Put the interface into the resource/config database.
    uvm_config_db#(virtual add_sub_dummy_if)::set(null,"*", "add_sub_dummy_if", m_if);
    environment = env::type_id::create("environment",null); // By older method you can give the m_if here also, read http://www.testbench.in/SL_05_PHASE_2_ENVIRONMENT.html
    //run_test();
  end
endmodule