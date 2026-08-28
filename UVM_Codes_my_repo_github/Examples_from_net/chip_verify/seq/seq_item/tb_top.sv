// Author   :   Admin (www.chipverify.com)
// Purpose  :   Example of how to run a sequence-item
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
   typedef class my_driver;               
   typedef class my_data;
   typedef class base_sequence;
 
   // Create an environment to hold the sequencer and driver, make the 
   // connection between them
   class my_env extends uvm_env ;
      `uvm_component_utils (my_env)
 
      my_driver                m_drv0;
      uvm_sequencer #(my_data) m_seqr0;
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
 
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
         m_seqr0 = uvm_sequencer#(my_data)::type_id::create ("m_seqr0", this);
      endfunction : build_phase
 
      virtual function void connect_phase (uvm_phase phase);
         super.connect_phase (phase);
         m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
      endfunction  
   endclass 
 
   // A simple description of a sequence item or data packet for our example
   class my_data extends uvm_sequence_item;
 
      rand bit [7:0]   data;
      rand bit [7:0]   addr;
 
      constraint c_addr { addr > 0; addr < 8;}
 
      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_object_utils_end
 
     function new (string name = "my_data");
       super.new (name);
     endfunction
   endclass   
 
   // Define the driver to accept sequence item from sequencer and display
   // In a real driver, the driver is also supposed to get handle for 
   // virtual interface from config_db and drive the sequence item
   // to its interface during run_phase() or main_phase()
   class my_driver extends uvm_driver #(my_data);
      `uvm_component_utils (my_driver)
 
      my_data           data_obj;
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction
 
      task main_phase (uvm_phase phase);
         super.main_phase (phase);
         forever begin
            `uvm_info (get_type_name (), $sformatf ("Waiting for data from sequencer"), UVM_MEDIUM)
            seq_item_port.get_next_item (data_obj);
            drive_item (data_obj);
            seq_item_port.item_done ();
         end
      endtask
 
      virtual task drive_item (my_data data_obj);
         `uvm_info ("DRV", $sformatf ("Driving data item across DUT interface"), UVM_HIGH)
         data_obj.print (uvm_default_tree_printer);
      endtask
   endclass
 
   // Define the sequence that will start executing a sequence item
   class base_sequence extends uvm_sequence #(my_data);
      `uvm_object_utils (base_sequence)
 
      my_data  data_obj;
 
      function new (string name = "base_sequence");
         super.new (name);
      endfunction
 
      virtual task body ();
         `uvm_info ("BASE_SEQ", $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)
         data_obj = my_data::type_id::create ("data_obj");
 
        repeat (5) begin
            start_item (data_obj);
            assert (data_obj.randomize ());
            finish_item (data_obj);
         end
         `uvm_info (get_type_name (), $sformatf ("Sequence %s is over", this.get_name()), UVM_MEDIUM)
      endtask
   endclass
 
 
class base_test extends uvm_test;
   `uvm_component_utils (base_test)
 
   my_env   m_top_env;
 
   function new (string name, uvm_component parent = null);
      super.new (name, parent);
   endfunction : new
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_top_env  = my_env::type_id::create ("m_top_env", this);
   endfunction
 
   virtual function void end_of_elaboration_phase (uvm_phase phase);
      uvm_top.print_topology ();
   endfunction
 
   // Create the sequence and start it on the specific sequencer
   virtual task main_phase (uvm_phase phase);
      base_sequence bs = base_sequence::type_id::create ("base_seq");
      super.main_phase (phase);
      phase.raise_objection (this);
      bs.start (m_top_env.m_seqr0);
      phase.drop_objection (this);
   endtask
endclass 
 
// Top testbench module to start running this test
module tb_top;
  initial 
    run_test ("base_test");
endmodule