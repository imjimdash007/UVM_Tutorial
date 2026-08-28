//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM TLM Port to Export to Imp 
// Category : UVM
// Link     : https://www.edaplayground.com/x/3aiy
// Filename : 273_uvm_tlm_port_to_export_to_imp__ex2.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author  : Admin, ChipVerify
// Website : www.chipverify.com
// Notes   :
// subCompA is trying to send to componentB crossing hierarchies
// All Ports/Exports are terminated by an IMP. Port to Port
// or Export to Export forwards packets. Port to Export connection
// happens at the top level of the hierarchy. Until then its all
// Port to Port and once Export is reached, it is all Export until
// it reaches IMP
//
// +--------------+   	+---------------+
// |    CompA     |   	| 	  CompB 	|
// | +----------+ |   	|               |
// | | subCompA P P   	I               |
// | +----------+ |  	|               |
// +--------------+  	+---------------+
//
 
 
`include "uvm_macros.svh"
import uvm_pkg::*;
typedef class subCompA;
 
 
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
 
 
// subCompA generates packets and sends to its Port
 
class subCompA extends uvm_component;
  `uvm_component_utils (subCompA)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
  uvm_blocking_put_port #(Packet) m_put_port;
  int m_num_tx=2;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_put_port = new ("m_put_port", this);
  endfunction
 
  // Create a packet, randomize it and send it through the port
  // Note that put() is a method defined by the receiving component
  // Repeat these steps N times to send N packets
   virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this);
     repeat (m_num_tx) begin
         Packet pkt = Packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
 
       	 // Print the packet to be displayed in log
       `uvm_info ("SUBCOMPA", "Packet sent to CompB", UVM_LOW)
         pkt.print (uvm_default_line_printer);
 
         // Call the TLM put() method of put_port class and pass packet as argument
         m_put_port.put (pkt);
      end
      phase.drop_objection(this);
   endtask
endclass
 
 
// ComponentA will get the packet from subCompA on its Port 
// and forward it to the connected export
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
   function new (string name = "componentA", uvm_component parent= null);
      super.new (name, parent);
   endfunction
 
    subCompA m_subcomp_A;
    uvm_blocking_put_port #(Packet) m_put_port;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_subcomp_A = subCompA::type_id::create("m_subcomp_A", this);
    m_put_port = new ("m_put_port", this);
  endfunction
 
  // Connection with subCompA
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_subcomp_A.m_put_port.connect(this.m_put_port);
  endfunction
endclass
 
 
// ComponentB gets the packet on its Export
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
  uvm_blocking_put_imp#(Packet, componentB) m_put_imp;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_put_imp = new("m_put_imp", this);
  endfunction
 
      // Implementation of the 'put()' method in this case simply prints it.
    virtual task put (Packet pkt);            
      `uvm_info ("COMPB", "Packet received from subCompA", UVM_LOW)
      pkt.print(uvm_default_line_printer);
   endtask
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
   endfunction
 
   // Connection between componentA and componentB is done here
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