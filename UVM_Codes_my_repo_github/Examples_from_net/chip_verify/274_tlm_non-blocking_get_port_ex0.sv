//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : TLM Non-blocking Get Port
// Category : UVM
// Link     : https://www.edaplayground.com/x/3BVb
// Filename : 274_tlm_non-blocking_get_port_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author  : Admin, ChipVerify
// Website : www.chipverify.com
// Notes   :
// componentB requests for a packet from componentA using get()
 
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
 
// Create a class data object that can be sent from one 
// component to another
 
class Packet extends uvm_object;
  rand bit[7:0] addr;
  rand bit[7:0] data;
 
  `uvm_object_utils_begin(Packet)
  	`uvm_field_int(addr, UVM_ALL_ON)
  	`uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end
 
  function new(string name = "Packet");
    super.new(name);
  endfunction
endclass
 
 
// ComponentB requests to get an item using the get_port and
// get() method call which is blocking in this example because
// we have used uvm_blocking_get_port
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
 
   // Create a get_port to request for data from componentA
   uvm_nonblocking_get_port #(Packet) m_get_port;
   int m_num_tx = 2;
 
  function new (string name, uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     m_get_port = new ("m_get_port", this);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      Packet pkt;
     phase.raise_objection(this);
 
     // Try to get a transaction which does not consume simulation time
     // as try_get() is a function
     repeat (m_num_tx) begin
`ifdef CAN_GET
 
       while (!m_get_port.can_get()) begin
         #10 `uvm_info("COMPB", $sformatf("See if can_get() is ready"), UVM_LOW)
       end
       `uvm_info("COMPB", $sformatf("COMPA ready, get packet now"), UVM_LOW)
       m_get_port.try_get(pkt);
 
`else       
       if (m_get_port.try_get(pkt))
       	`uvm_info ("COMPB", "ComponentA just gave me the packet", UVM_LOW)
       else
         `uvm_info ("COMPB", "ComponentA did not give packet", UVM_LOW)
`endif         
        pkt.print (uvm_default_line_printer);
      end
     phase.drop_objection(this);
   endtask
endclass
 
 
// ComponentA implements the get() call by returning a packet
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
 
   uvm_nonblocking_get_imp #(Packet, componentA) m_get_imp;
 
  function new (string name, uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_get_imp = new ("m_get_imp", this);
   endfunction
 
   virtual function bit try_get (output Packet pkt);
      pkt = new();
      assert (pkt.randomize());
      `uvm_info ("COMPA", "ComponentB has requested for a packet", UVM_LOW)
      pkt.print (uvm_default_line_printer);
      return 1;
   endfunction
 
     virtual function bit can_get();
`ifdef CAN_GET       
       bit ready;
       std::randomize(ready) with { ready dist {0:/70, 1:/30}; };
       return ready;
`endif   
     endfunction
endclass
 
class my_test extends uvm_test;
  `uvm_component_utils (my_test)
 
   componentA compA;
   componentB compB;
 
  function new (string name = "my_test", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   // Create objects of both components, set number of transfers
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      compA = componentA::type_id::create ("compA", this);
      compB = componentB::type_id::create ("compB", this);
   endfunction
 
   // Connection between componentA and componentB is done here
   virtual function void connect_phase (uvm_phase phase);
     compB.m_get_port.connect (compA.m_get_imp);  
   endfunction
 
   virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass
 
 
// Testbench top module starts running UVM test
 
module tb;
  initial
    run_test("my_test");
endmodule