//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : TLM Fifo [uvm_tlm_fifo]
// Category : UVM
// Link     : https://www.edaplayground.com/x/5jQ6
// Filename : 100_tlm_fifo_[uvm_tlm_fifo]_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
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
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
 
  // Create a blocking TLM put port which can send an object
  // of type 'Packet'
  uvm_blocking_put_port #(Packet) m_put_port;
  int m_num_tx = 2;
 
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
         Packet pkt = Packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
 		#50;
          // Print the packet to be displayed in log
         `uvm_info ("COMPA", "Packet sent to CompB", UVM_LOW)
         pkt.print (uvm_default_line_printer);
 
         // Call the TLM put() method of put_port class and pass packet as argument
         m_put_port.put (pkt);
      end
 
`ifdef FLUSH
     `uvm_info("COMPA", "Exercising tlm_fifo flush", UVM_LOW)
     // Lets push two more data into the FIFO to make it full
     repeat (2) begin
       Packet pkt = Packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
         m_put_port.put(pkt);
     end
`endif
      phase.drop_objection(this);
   endtask
endclass
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
 
   // Create a get_port to request for data from componentA
   uvm_blocking_get_port #(Packet) m_get_port;
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
     repeat (m_num_tx) begin
       #100;
         m_get_port.get (pkt);
         `uvm_info ("COMPB", "ComponentA just gave me the packet", UVM_LOW)
        pkt.print (uvm_default_line_printer);
      end
     phase.drop_objection(this);
   endtask
endclass
 
class my_test extends uvm_env;
  `uvm_component_utils (my_test)
 
   componentA compA;
   componentB compB;
 
   int m_num_tx;
 
   // Create the UVM TLM Fifo that can accept simple_packet
   uvm_tlm_fifo #(Packet)    m_tlm_fifo;
 
  function new (string name = "my_test", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      compA = componentA::type_id::create ("compA", this);
      compB = componentB::type_id::create ("compB", this);
     std::randomize(m_num_tx) with { m_num_tx inside {[4:10]}; };
     compA.m_num_tx = m_num_tx;
     compB.m_num_tx = m_num_tx;
 
      // Create a FIFO with depth 2
      m_tlm_fifo = new ("uvm_tlm_fifo", this, 2);
   endfunction
 
   // Connect the ports to the export of FIFO.
   virtual function void connect_phase (uvm_phase phase);
     compA.m_put_port.connect(m_tlm_fifo.put_export);
     compB.m_get_port.connect(m_tlm_fifo.get_export);
   endfunction
 
   // Display a message when the FIFO is full
   virtual task run_phase (uvm_phase phase);
      forever begin
        #10;
        if (m_tlm_fifo.is_full ())
          `uvm_info ("UVM_TLM_FIFO", "Fifo is now FULL !", UVM_MEDIUM)          
      end
   endtask
endclass
 
 
// Testbench top module starts running UVM test
 
module tb;
  initial
    run_test("my_test");
endmodule