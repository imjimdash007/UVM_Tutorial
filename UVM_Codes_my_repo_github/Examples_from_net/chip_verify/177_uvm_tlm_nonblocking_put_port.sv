//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM TLM Nonblocking Put Port
// Category : UVM
// Link     : https://www.edaplayground.com/x/5HCD
// Filename : 177_uvm_tlm_nonblocking_put_port_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author  : Admin, ChipVerify
// Website : www.chipverify.com
 
 
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
 
 
// ComponentA will send packets to ComponentB
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
 
  // Create a nonblocking TLM put port which can send an object
  // of type 'Packet'
  uvm_nonblocking_put_port #(Packet) m_put_port;
  int m_num_tx;
 
   function new (string name = "componentA", uvm_component parent= null);
      super.new (name, parent);
   endfunction
 
   // Remember that TLM put_port is a class object and it will have to be 
   // created with new ()
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     m_put_port = new ("m_put_port", this);
   endfunction
 
  // Create a packet, randomize it and send it through the port
  // Note that put() is a method defined by the receiving component
  // Repeat these steps N times to send N packets
   virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this);
     repeat (m_num_tx) begin
        bit success;
         Packet pkt = Packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
 
        // Print the packet to be displayed in log
         `uvm_info ("COMPA", "Packet sent to CompB", UVM_LOW)
         pkt.print (uvm_default_line_printer);
 
 
         success = m_put_port.try_put(pkt);
         if (success) 
           `uvm_info("COMPA", $sformatf("COMPB was ready to accept and transfer is successful"), UVM_MEDIUM)
         else
           `uvm_info("COMPA", $sformatf("COMPB was NOT ready to accept and transfer failed"), UVM_MEDIUM)
      end
     phase.drop_objection(this);
   endtask
endclass
 
 
// ComponentB will receive packets from ComponentA
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
 
   // Mention type of transaction, and type of class that implements the put ()
  uvm_nonblocking_put_imp #(Packet, componentB) m_put_imp;
 
   function new (string name = "componentB", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_put_imp = new ("m_put_imp", this);
   endfunction
 
  // 'try_put' method definition accepts the packet and prints it.
  // Note that it should return 1 if successful so that componentA
  // knows how to handle the transfer return code
  virtual function bit try_put (Packet pkt);
      `uvm_info ("COMPB", "Packet received", UVM_LOW)
      pkt.print(uvm_default_line_printer);
      return 1;
  endfunction
 
  virtual function bit can_put();
  endfunction
 
endclass
 
 
// Test class instantiates both components and connects them
 
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
      compA.m_num_tx = 2;
   endfunction
 
   // Connection between componentA and componentB is done here
   // Note that the "put_port" is connected to its implementation "put_imp"
   virtual function void connect_phase (uvm_phase phase);
     compA.m_put_port.connect (compB.m_put_imp);  
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