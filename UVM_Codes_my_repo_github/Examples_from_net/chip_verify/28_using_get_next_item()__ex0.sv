//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : Using get_next_item() 
// Category : UVM
// Link     : https://www.edaplayground.com/x/4sFy
// Filename : 28_using_get_next_item()__ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
 
 
`timescale 1ns/1ns
`include "uvm_macros.svh"
import uvm_pkg::*;
 
// This is the main sequence item class that will be used to create
// transactions such that it is sent to the driver from the sequencer
class my_data extends uvm_sequence_item;
  rand bit [7:0]   data;
  rand bit [7:0]   addr;
 
  `uvm_object_utils_begin (my_data)
     `uvm_field_int (data, UVM_ALL_ON)
     `uvm_field_int (addr, UVM_ALL_ON)
  `uvm_object_utils_end
 
  function new (string name="my_data");
    super.new(name);
  endfunction
endclass   
 
// This driver class will call "get_next_item" and "item_done" methods to communicate
// with the sequencer. Note that this driver is parameterized with "my_data"
// and hence it can accept only sequence items of type "my_data" and anything
class my_driver extends uvm_driver #(my_data);
   `uvm_component_utils (my_driver)
   function new (string name, uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info ("DRIVER", $sformatf ("Waiting for data from sequencer"), UVM_MEDIUM)
      seq_item_port.get_next_item(req);
      `uvm_info ("DRIVER", $sformatf ("Start driving tx addr=0x%0h data=0x%0h", req.addr, req.data), UVM_MEDIUM)
      #20;
      `uvm_info ("DRIVER", $sformatf ("Finish driving tx addr=0x%0h data=0x%0h", req.addr, req.data), UVM_MEDIUM)
      seq_item_port.item_done();
   endtask
endclass
 
// This is the main sequence that will be executed by the sequencer in
// this environment. The sequence constructs sequence items and the sequencer
// FIFO is filled with these sequence items. When the driver asks for the next
// sequence item, the sequencer will pop the item and provided to the driver
class my_sequence extends uvm_sequence;
  `uvm_object_utils (my_sequence)
  function new(string name = "my_sequence");
    super.new(name);
  endfunction
 
  virtual task body();
    my_data tx = my_data::type_id::create("tx");
    `uvm_info ("SEQ", $sformatf("About to call start_item"), UVM_MEDIUM)
    start_item(tx);
    `uvm_info ("SEQ", $sformatf("start_item() fn call done"), UVM_MEDIUM)
    tx.randomize();
    `uvm_info ("SEQ", $sformatf("tx randomized with addr=0x%0h data=0x%0h", tx.addr, tx.data), UVM_MEDIUM)
    finish_item(tx);
    `uvm_info ("SEQ", $sformatf("finish_item() fn call done"), UVM_MEDIUM)
  endtask
endclass 
 
 
// This is the base test class in which we will start the main sequence
// on the given sequencer
class base_test extends uvm_test;
  `uvm_component_utils (base_test)
  function new (string name, uvm_component parent = null);
     super.new (name, parent);
  endfunction : new
 
   my_driver                m_drv0;
   uvm_sequencer #(my_data) m_seqr0;
  my_sequence   m_seq;
 
  virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
          m_drv0 = my_driver::type_id::create ("m_drv0", this);
      m_seqr0 = uvm_sequencer#(my_data)::type_id::create ("m_seqr0", this);
  endfunction
 
  // Connect the sequencer "export" to the driver's "port"
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
  endfunction
 
  virtual task run_phase(uvm_phase phase);
    m_seq = my_sequence::type_id::create("m_seq");    
    phase.raise_objection(this);
    m_seq.start(m_seqr0);
    phase.drop_objection(this);
  endtask
endclass 
 
module tb_top;
   initial run_test ("base_test");
endmodule