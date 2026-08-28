//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------
 
`include "uvm_macros.svh"
 
package my_pkg;
   // If you don't use this, it'll complain that it doesn't recognize uvm components
   import uvm_pkg::*;
 
   typedef class my_driver;               
   typedef class my_data;
 
   // Environment class to hold a driver and a sequencer
   class my_env extends uvm_env ;
      `uvm_component_utils (my_env)
 
      my_driver      m_drv0;
      uvm_sequencer  m_seqr0;
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
 
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
         m_seqr0 = uvm_sequencer::type_id::create ("m_seqr0", this);
      endfunction : build_phase
 
      // Make the connection between sequencer and driver so that the 
      // sequencer can send data items to the driver
      virtual function void connect_phase (uvm_phase phase);
         super.connect_phase (phase);
         m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
      endfunction
   endclass 
 
   // Define a custom data packet just for fun
   class my_data extends uvm_sequence_item;
      rand bit [7:0]   data;
      rand bit [7:0]   addr;
 
      constraint c_addr { addr > 8'h0; addr < 8'hc2;}
 
      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_object_utils_end
   endclass   
 
   // A normal driver would accept interface from config_db and write values to it's pins
   // For our purpose let's skip that and simply display contents of the packet
   class my_driver extends uvm_driver;
      `uvm_component_utils (my_driver)
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction
 
      task main_phase (uvm_phase phase);
         super.main_phase (phase);
         forever begin
            `uvm_info (get_type_name (), "Waiting for data from sequencer", UVM_MEDIUM)
            seq_item_port.get_next_item (req);
            `uvm_info ("DRVR", "Driving data onto bus ...", UVM_MEDIUM)
            req.print();
            seq_item_port.item_done ();
         end
      endtask
   endclass
 
   // This is the main sequence that will be executed by the sequencer
   // We'll try four macros one after the other 
   // `uvm_do
   // `uvm_do_with
   // `uvm_do_pri
   // `uvm_do_pri_with
   class seq1 extends uvm_sequence #(my_data);
      `uvm_object_utils (seq1)
 
      function new (string name = "seq1");
         super.new (name);
      endfunction
 
      virtual task body ();
         `uvm_info (get_type_name(), $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)
         `uvm_do (req)
         `uvm_do_with (req, { data == 8'h4e;
                              addr == 8'ha1;})
         `uvm_do_pri (req, 9)
         `uvm_do_pri_with (req, 3, { data == 8'hc5; })
         `uvm_info (get_type_name(), $sformatf ("Sequence %s is over", this.get_name()), UVM_MEDIUM)
      endtask
   endclass
 
   // Test class is used to start and run a particular sequence on a particular sequencer
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
 
      virtual task main_phase (uvm_phase phase);
         seq1  m_seq = seq1::type_id::create ("m_seq"); 
         super.main_phase (phase);
 
         phase.raise_objection (this);
         m_seq.start (m_top_env.m_seqr0);
         phase.drop_objection (this);
      endtask
 
   endclass 
endpackage