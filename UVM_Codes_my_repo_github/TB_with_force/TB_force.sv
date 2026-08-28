//Design.v -->
// Author Ajay Dash , Date 16/Dec/2020

// Simple adder RTL  --> Consider this as your design and this is pure Verilog design

// We need to connect RTL inside signals to some class based task

// Since we cannot do it, directly we need to use
//  1. Virtual interface --> Virtual Interface is required to connect RTL (Design) to Class (TB components)
//  2. We need to use config_db SET/GET -> "set" will add the VI in the DB (RTL), "get" when we need to connect in any component form the DB (TB components)
//  3. Since we use the hierarchy to assign the VI so that TB components can also be used to snoop or drive RTL ports/deep inside signals 
//  4. In this example we will control the doAdd0 to ADD/SUB , if doAdd0 == 1 + , else -

module ADD_SUB(
  input            clk,
  input [7:0]      a0,
  input [7:0]      b0,
  // if this is 1, add; else subtract
  input            doAdd0,
  output reg [8:0] result0
);
  always @ (posedge clk)
    begin
      if (doAdd0)
        result0 <= a0 + b0;
      else
        result0 <= a0 - b0;
    end
endmodule

//                                                 ''~``
//                                                 ( o o )
//                         +------------------.oooO--(_)--Oooo.------------------+
//                         |                                                     |
//                         |                                                     |
//                         |                    ~~~AJ~~~                         |
//                         |                                                     |
//                         |                    .oooO                            |
//                         |                    (   )   Oooo.                    |
//                         +---------------------\ (----(   )--------------------+
//                                                \_)    ) /
//                                                      (_/

//env.sv --> class where you want to force/read the design ports/signals 
// Author Ajay Dash, Date 16/Dec/2020

// Interface is assigned as Virtual interface in the class and it can drive or snoop the RTL signals/ports etc
//Class based stuffs

import uvm_pkg::*;
`include "uvm_macros.svh"

//--------------------------------------------------------------
// environment env
//--------------------------------------------------------------
class env extends uvm_env;

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
       force top_tb.TB_COMP.m_if.a = 8'h2;  //Whatever you want to force 
       force top_tb.TB_COMP.m_if.b = 8'h3;
       force top_tb.TB_COMP.m_if.doAdd = 'b1;
      repeat(3) @(m_en_if.clk);  //waiting for the clk (Hint: it can be some deep signal if you have assign the same from the design )
      `uvm_info("RESULT     TB", $sformatf("%0d + %0d = %0d", 2, 3, m_en_if.result), UVM_LOW);
    end
    `uvm_info("LABEL", "Finished run phase.", UVM_LOW);
    #400;
    phase.drop_objection(this);
  endtask: run_phase
endclass


//hold_module.sv --> used for the interface + config_db set 


`define hier top_tb.dut    //for the hierarchy
//`include "env.sv"

import uvm_pkg::*;
`include "uvm_macros.svh"

//Added a new interface for SB/Monitor only

interface add_sub_dummy_if(
  input bit clk,
  output [7:0] a,
  output [7:0] b,
  output       doAdd,
  input [8:0] result
);
endinterface: add_sub_dummy_if

//-------------------------------------------------------------
module hold;
  add_sub_dummy_if m_if();
  env      environment;
  assign   m_if.clk =  `hier.clk;
  assign  `hier.a0 = m_if.a;
  assign  `hier.b0 = m_if.b;
  assign  `hier.doAdd0 = m_if.doAdd;
  assign   m_if.result = `hier.result0;
 
  initial begin
    // Put the interface into the resource/config database.
    uvm_config_db#(virtual add_sub_dummy_if)::set(null,"*", "add_sub_dummy_if", m_if);
    environment = new("env2"); // By older method you can give the m_if here also, read http://www.testbench.in/SL_05_PHASE_2_ENVIRONMENT.html
  end
endmodule


//testbench.sv  --> Top level TB --> Where you will call hold module  /or even with out calling also it should work

// Author Ajay Dash, Date 16/Dec/2020

// This is a simple TB, which have the DUT

// Also it makes an ENV (this is the class, where we have different components which we will connect the design, via hiearchy and virtual interface

import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------
// module top_tb
//------------------------------------
module top_tb;
  bit clk;
  //env environment;
  ADD_SUB dut(.clk (clk));

  hold TB_COMP();
 
  initial begin
    // Put the interface into the resource database.
    clk = 0;
    run_test();
  end
   initial begin
    forever begin
      #(50) clk = ~clk;
    end
  end
endmodule