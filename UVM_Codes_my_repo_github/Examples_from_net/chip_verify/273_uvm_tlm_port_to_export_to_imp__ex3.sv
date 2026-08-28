//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM TLM Port to Export to Imp 
// Category : UVM
// Link     : https://www.edaplayground.com/x/3dpQ
// Filename : 273_uvm_tlm_port_to_export_to_imp__ex3.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author  : Admin, ChipVerify
// Website : www.chipverify.com
// Notes   :
// subCompA is trying to send to subCompB crossing hierarchies
// All Ports/Exports are terminated by an IMP. Port to Port
// or Export to Export forwards packets. Port to Export connection
// happens at the top level of the hierarchy. Until then its all
// Port to Port and once Export is reached, it is all Export until
// it reaches IMP
//
// +--------------+   	+---------------+
// |    CompA     |   	| 	  CompB 	|
// |              |   	| +-----------+ |
// |              P   	E I subCompB  | |
// |              |  	| +-----------+ |
// +--------------+  	+---------------+
//
 
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
typedef class subCompB;
 
 
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
 
 
// ComponentA will start the packet and send on its Port 
// to the connected export
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
   function new (string name = "componentA", uvm_component parent= null);
      super.new (name, parent);
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
       `uvm_info ("SUBCOMPA", "Packet sent to subCompB", UVM_LOW)
         pkt.print (uvm_default_line_printer);
 
         // Call the TLM put() method of put_port class and pass packet as argument
         m_put_port.put (pkt);
      end
      phase.drop_objection(this);
   endtask
endclass
 
 
// ComponentB gets the packet on its Export
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
	subCompB m_subcomp_B;
   uvm_blocking_put_export#(Packet) m_put_export;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_subcomp_B = subCompB::type_id::create("m_subcomp_B", this);
    m_put_export = new("m_put_export", this);
  endfunction
 
  // Connection with subCompB
  virtual function void connect_phase(uvm_phase phase);
    m_put_export.connect(m_subcomp_B.m_put_imp);
  endfunction
endclass
 
 
// subCompB implements the "put" method and gets the packet via
// its implementation port IMP
 
class subCompB extends uvm_component;
  `uvm_component_utils (subCompB)
  function new (string name = "subCompB", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   // Mention type of transaction, and type of class that implements the put ()
  uvm_blocking_put_imp #(Packet, subCompB) m_put_imp;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     m_put_imp = new ("m_put_imp", this);
   endfunction
 
    // Implementation of the 'put()' method in this case simply prints it.
  	virtual task put (Packet pkt);            
      `uvm_info ("SUBCOMPB", "Packet received from componentA", UVM_LOW)
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
     compA.m_put_port.connect (compB.m_put_export);  
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