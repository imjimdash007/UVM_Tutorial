// Author   :  Admin    (www.chipverify.com)
// Purpose  :  Example of uvm macros
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
// A simple packet with a single data item
class packet extends uvm_sequence_item;
   function new (string name = "packet");
      super.new (name);
   endfunction
 
   rand bit [31:0] addr;
 
   `uvm_object_utils_begin (packet)
      `uvm_field_int (addr, UVM_ALL_ON)
   `uvm_object_utils_end
endclass
 
// The driver accepts data item from sequencer and prints it
class my_driver extends uvm_driver #(packet);
   `uvm_component_utils (my_driver)
   function new (string name="my_driver", uvm_component parent=null);
      super.new (name, parent);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      forever begin
         seq_item_port.get_next_item (req);
         `uvm_info ("DRVR", "Received item from sequencer", UVM_MEDIUM)
         req.print();
         seq_item_port.item_done ();
      end
   endtask
endclass
 
// The sequence starts an item using uvm macros
class base_seq extends uvm_sequence;
   `uvm_object_utils (base_seq)
   function new (string name="base_seq");
      super.new (name);
   endfunction
 
   packet pkt;
 
   task body();
      `uvm_info ("BS", "Create a packet ...", UVM_MEDIUM)
      `uvm_create (pkt);
      pkt.print();
      `uvm_info ("BS", "Randomize packet ...", UVM_MEDIUM)
      pkt.randomize() with { addr < 32'h1000_0000; };
      pkt.print();
      `uvm_info ("BS", "Send item to sequencer ...", UVM_MEDIUM)
      `uvm_send (pkt);
   endtask
endclass
 
// Test to hold env and run the sequence
class my_test extends uvm_test;
   `uvm_component_utils (my_test)
 
   my_driver                  m_drv;
   uvm_sequencer #(packet)    m_seqr;
   base_seq                   bs;
 
   function new (string name="my_test", uvm_component parent=null);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_drv = my_driver::type_id::create ("m_drv", this);
      m_seqr = uvm_sequencer #(packet)::type_id::create ("m_seqr", this);
      bs = base_seq::type_id::create ("bs");
   endfunction
 
   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_drv.seq_item_port.connect (m_seqr.seq_item_export);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      super.run_phase (phase);
      phase.raise_objection (this);
      bs.start (m_seqr);
      phase.drop_objection (this);
   endtask
endclass
 
// Top-level module to kick-start the UVM code
module tb_top;
   initial
      run_test ("my_test");
endmodule