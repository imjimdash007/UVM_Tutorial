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


import uvm_pkg::*;
`include "uvm_macros.svh"


class simple_test extends uvm_test;
  `uvm_component_utils(simple_test)
  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
 
  task run_phase(uvm_phase phase);
    #1000;
  endtask: run_phase
endclass


//------------------------------------
// module top_tb
//------------------------------------
module top_tb;
  bit clk;
  //env environment;
  ADD_SUB dut(.clk (clk));

 initial begin
    // Put the interface into the resource database.
    clk = 0;
    run_test("simple_test");
    #1000;
    $finish;
  end
   initial begin
    forever begin
      #(50) clk = ~clk;
    end
  end
endmodule

