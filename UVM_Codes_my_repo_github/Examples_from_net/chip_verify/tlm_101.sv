//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM TLM Example
// Category : UVM
// Link     : https://www.edaplayground.com/x/2YpD
// Filename : 101_uvm_tlm_example_ex0.sv
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
 
class subComp1 extends uvm_component;
   `uvm_component_utils (subComp1)
 
  // Create a blocking TLM put port which can send an object
  // of type 'Packet'
  uvm_blocking_put_port #(Packet) m_put_port;
  int m_num_tx;
 
   function new (string name = "subComp1", uvm_component parent= null);
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
     repeat (m_num_tx) begin
         Packet pkt = Packet::type_id::create ("pkt");
         assert(pkt.randomize ()); 
 		#50;
          // Print the packet to be displayed in log
       `uvm_info ("SUBCOMP1", "Packet sent to compA:tlm_fifo", UVM_LOW)
         pkt.print (uvm_default_line_printer);
 
         // Call the TLM put() method of put_port class and pass packet as argument
         m_put_port.put (pkt);
      end
   endtask   
endclass
 
class subComp2 extends uvm_component;
   `uvm_component_utils (subComp2)
 
   // Create a get_port to request for data from subComp1
   uvm_blocking_get_port #(Packet) m_get_port;
  uvm_blocking_put_port #(Packet) m_put_port;
 
  function new (string name, uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_get_port = new ("m_get_port", this);
     m_put_port = new ("m_put_port", this);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      Packet pkt;
      forever begin
       #100;
         m_get_port.get (pkt);
        `uvm_info ("SUBCOMP2", "Packet received from compA:tlm_fifo, forward it", UVM_LOW)
        pkt.print (uvm_default_line_printer);
        m_put_port.put(pkt);
      end
   endtask
endclass
 
class componentA extends uvm_component;
   `uvm_component_utils (componentA)
  function new(string name="componentA", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
   subComp1 m_subcomp_1;
   subComp2 m_subcomp_2;
 
   uvm_tlm_fifo #(Packet)    		m_tlm_fifo;
   uvm_blocking_put_port #(Packet)  m_put_port;
   int 								m_num_tx;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
      m_subcomp_1 = subComp1::type_id::create ("m_subcomp_1", this);
      m_subcomp_2 = subComp2::type_id::create ("m_subcomp_2", this);
 
      // Create a FIFO with depth 2
      m_tlm_fifo = new ("uvm_tlm_fifo", this, 2);
      m_put_port = new ("m_put_port", this);
      m_subcomp_1.m_num_tx = m_num_tx;
   endfunction
 
   // Make componentA connections
   virtual function void connect_phase (uvm_phase phase);
     // Connect put port from subComp1 to TLM FIFO and then 
     // connect get_export of TLM FIFO with subComp2
     m_subcomp_1.m_put_port.connect(m_tlm_fifo.put_export);
     m_subcomp_2.m_get_port.connect(m_tlm_fifo.get_export);
 
     // Now connect subComp2 to componentA for forwarding pkt
     m_subcomp_2.m_put_port.connect(this.m_put_port);
   endfunction
 
   // Display a message when the FIFO is full
   virtual task run_phase (uvm_phase phase);
      forever begin
        #10 if (m_tlm_fifo.is_full ()) 
          `uvm_info ("COMPA", "componentA:TLM_Fifo is now FULL !", UVM_MEDIUM)
      end
   endtask
endclass
 
// subComp3 accepts packet even slower than what componentA is sending out          
// which is the reason we need a TLM FIFO in componentB
class subComp3 extends uvm_component;
  `uvm_component_utils (subComp3)
 
   // Create a get_port to request for data from subComp1
   uvm_blocking_get_port #(Packet) m_get_port;
   int m_num_tx;
 
  function new (string name, uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_get_port = new ("m_get_port", this);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      Packet pkt;
     repeat(m_num_tx) begin
        #200;
        m_get_port.get (pkt);
        `uvm_info ("SUBCOMP3", "Packet received from componentA", UVM_LOW)
        pkt.print (uvm_default_line_printer);
      end
   endtask
endclass
 
class componentB extends uvm_component;
   `uvm_component_utils (componentB)
 
   subComp3                    			m_subcomp_3;
  uvm_tlm_fifo #(Packet)    			m_tlm_fifo;
   uvm_blocking_put_export #(Packet) 	m_put_export;
   int 									m_num_tx;
 
   function new (string name = "componentB", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      // Create an object of both components
     m_subcomp_3 = subComp3::type_id::create ("m_subcomp_3", this);
 
      // Create a FIFO with depth 2
      m_tlm_fifo = new ("tlm_fifo", this, 2);
 
      // Create the export to connect with componentA
     m_put_export = new ("m_put_export", this);
 
     m_subcomp_3.m_num_tx = m_num_tx;
   endfunction
 
   virtual function void connect_phase (uvm_phase phase);
      // Connect from componentB export to FIFO export
     m_put_export.connect (m_tlm_fifo.put_export);
 
      // Connect from FIFO export to subComponent3 port 
     m_subcomp_3.m_get_port.connect (m_tlm_fifo.get_export);
   endfunction
 
     // Display a message when the FIFO is full
   virtual task run_phase (uvm_phase phase);
      forever begin
        #10 if (m_tlm_fifo.is_full ()) 
          `uvm_info ("COMPB", "componentB:TLM_Fifo is now FULL !", UVM_MEDIUM)
      end
   endtask
endclass
 
class my_test extends uvm_env;
  `uvm_component_utils (my_test)
 
  componentA compA;
  componentB compB;
  int 		 m_num_tx;
 
  function new (string name = "my_test", uvm_component parent = null);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
     compA = componentA::type_id::create("componentA", this);
     compB = componentB::type_id::create("componentB", this);
 
     std::randomize(m_num_tx) with { m_num_tx inside {[4:10]}; };
     `uvm_info("TEST", $sformatf("Create %0d packets in total", m_num_tx), UVM_LOW)
     compA.m_num_tx = m_num_tx;
     compB.m_num_tx = m_num_tx;
   endfunction
 
   // Connect the ports to the export of FIFO.
   virtual function void connect_phase (uvm_phase phase);
     compA.m_put_port.connect(compB.m_put_export);
   endfunction
 
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // Let all components finish for purpose of illustration
    phase.raise_objection(this);
    #1000;
    phase.drop_objection(this);
  endtask
endclass
 
 
// Testbench top module starts running UVM test
 
module tb;
  initial
    run_test("my_test");
endmodule