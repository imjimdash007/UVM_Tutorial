// Testing the concepts date 17 May 2019

import uvm_pkg::*;
`include "uvm_macros.svh"

module top;

  class test extends uvm_test;
   `uvm_component_utils (test)
    
    function new( string name, uvm_component parent = null);
      super.new(name,parent);
    endfunction   
     
    function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info(">>>BUILD<<<", "Hello World! from Build",UVM_MEDIUM)
    endfunction 

     function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info(">>>CONNECT<<<", "Hello World! from CONNECT",UVM_MEDIUM)
    endfunction 
      
     
    task run_phase(uvm_phase phase);
       super.run_phase(phase);
         phase.raise_objection(this);
           uvm_top.print_topology();
            #10;
           `uvm_info("TEST", "Hello World!",UVM_LOW)
         phase.drop_objection(this);
    endtask
  endclass : test

   initial begin 
    // automatic test c = new("c");
    test c;
    c = test::type_id::create("c",null);
    run_test();
   end

endmodule: top


 //git log --stat Hello_world.sv
