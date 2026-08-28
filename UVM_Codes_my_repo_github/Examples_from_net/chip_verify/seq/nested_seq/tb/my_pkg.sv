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
   typedef class base_sequence;
 
   class my_sequencer extends uvm_sequencer #(my_data);
      `uvm_component_utils (my_sequencer)
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction
   endclass
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_env   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_env extends uvm_env ;
      `uvm_component_utils (my_env)
 
      my_driver   m_drv0;
      my_sequencer m_seqr0;
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction : new
 
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         m_drv0 = my_driver::type_id::create ("m_drv0", this);
         m_seqr0 = my_sequencer::type_id::create ("m_seqr0", this);
      endfunction : build_phase
 
      virtual function void connect_phase (uvm_phase phase);
         super.connect_phase (phase);
         m_drv0.seq_item_port.connect (m_seqr0.seq_item_export);
      endfunction
 
   endclass : my_env
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_data  {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_data extends uvm_sequence_item;
 
      rand bit [7:0]   data;
      rand bit [7:0]   addr;
 
      constraint c_addr { addr > 8'h0; addr < 8'hc2;}
 
      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_object_utils_end
 
   endclass   
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_driver   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class my_driver extends uvm_driver #(my_data);
      `uvm_component_utils (my_driver)
 
      my_data           data_obj;
      virtual  dut_if   vif;
 
      function new (string name, uvm_component parent);
         super.new (name, parent);
      endfunction
 
      virtual function void build_phase (uvm_phase phase);
         super.build_phase (phase);
         if (! uvm_config_db #(virtual dut_if) :: get (this, "", "vif", vif)) begin
            `uvm_fatal (get_type_name (), "Didn't get handle to virtual interface dut_if")
         end
 
      endfunction
 
      task reset_phase (uvm_phase phase);
         super.reset_phase (phase);
         phase.raise_objection (phase);
         `uvm_info (get_type_name (), $sformatf ("Applying initial reset"), UVM_MEDIUM)
         this.vif.rstn = 0;
         repeat (20) @ (posedge vif.clk);
         this.vif.rstn = 1;
         `uvm_info (get_type_name (), $sformatf ("DUT is now out of reset"), UVM_MEDIUM)
         phase.drop_objection (phase);
      endtask
 
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
         @(posedge vif.clk);
         this.vif.en    = 1;
         this.vif.wr    = 1;
         this.vif.addr  = data_obj.addr;
         this.vif.wdata = data_obj.data;
         `uvm_info ("DRV", $sformatf ("Driving data item across DUT interface"), UVM_HIGH)
         data_obj.print (uvm_default_tree_printer);
      endtask
 
      task shutdown_phase (uvm_phase phase);
         super.shutdown_phase (phase);
         `uvm_info (get_type_name(), "Finished DUT simulation", UVM_LOW)
      endtask
 
   endclass
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_sequence   {{{1
   //---------------------------------------------------------------------------------------------------------------------
   class base_sequence extends uvm_sequence #(my_data);
      `uvm_object_utils (base_sequence)
      `uvm_declare_p_sequencer (my_sequencer)
 
      function new (string name = "base_sequence");
         super.new (name);
      endfunction
 
      virtual function void mid_do (uvm_sequence_item this_item);
         `uvm_info (get_type_name (), "Executing mid_do", UVM_MEDIUM)
      endfunction
 
      virtual task pre_do (bit is_item);
         `uvm_info (get_type_name (), "Executing pre_do", UVM_MEDIUM)
      endtask
 
      virtual function void post_do (uvm_sequence_item this_item);
         `uvm_info (get_type_name (), "Executing post_do", UVM_MEDIUM)
      endfunction
 
      virtual task body ();
         starting_phase.raise_objection (this);
         `uvm_info ("BASE_SEQ", $sformatf ("Starting body of %s", this.get_name()), UVM_MEDIUM)
         `uvm_info ("BASE_SEQ", $sformatf ("Sequence %s is over", this.get_name()), UVM_MEDIUM)
         starting_phase.drop_objection (this);
      endtask
   endclass
 
   typedef class seq2;
   typedef class seq3;
 
   //----------------------------------------------------------------------------------------------------------------------
   //                                                       seq1
   //----------------------------------------------------------------------------------------------------------------------
   class seq1 extends base_sequence;
      `uvm_object_utils (seq1)
 
      seq2 m_seq2;
 
      virtual task pre_start ();
         `uvm_info (get_type_name (), "Executing pre_start()", UVM_MEDIUM)
      endtask
 
      function new (string name = "seq1");
         super.new (name);
      endfunction
 
      virtual task body ();
         starting_phase.raise_objection (this);
         m_seq2 = seq2::type_id::create ("m_seq2");
         `uvm_info ("SEQ1", "Starting seq1", UVM_MEDIUM)
         m_seq2.start (p_sequencer, null, , 0);
         `uvm_info ("SEQ1", "Ending seq1", UVM_MEDIUM)
         starting_phase.drop_objection (this);
      endtask
 
   endclass
 
   //----------------------------------------------------------------------------------------------------------------------
   //                                                       seq2
   //----------------------------------------------------------------------------------------------------------------------
   class seq2 extends base_sequence;
      `uvm_object_utils (seq2)
 
      seq3 m_seq3;
 
      function new (string name = "seq2");
         super.new (name);
      endfunction
 
      virtual task pre_body ();
         `uvm_info (get_type_name(), "Executing pre_body", UVM_MEDIUM)
      endtask      
 
      virtual task body ();
         m_seq3 = seq3::type_id::create ("m_seq3");
         `uvm_info ("SEQ2", "Starting seq2", UVM_MEDIUM)
         #10;
         m_seq3.start (p_sequencer, this, , 1);
         `uvm_info ("SEQ2", "Ending seq2", UVM_MEDIUM)
      endtask
 
      virtual task post_body ();
         `uvm_info (get_type_name(), "Executing post_body", UVM_MEDIUM)
      endtask    
 
   endclass
 
   //----------------------------------------------------------------------------------------------------------------------
   //                                                       seq3
   //----------------------------------------------------------------------------------------------------------------------
   class seq3 extends base_sequence;
      `uvm_object_utils (seq3)
 
      function new (string name = "seq3");
         super.new (name);
      endfunction
 
      virtual task pre_body ();
         `uvm_info (get_type_name(), "Executing pre_body", UVM_MEDIUM)
      endtask      
 
      virtual task body ();
         `uvm_info ("SEQ3", "Starting seq3", UVM_MEDIUM)
         #10;
         `uvm_info ("SEQ3", "Ending seq3", UVM_MEDIUM)
      endtask
 
      virtual task post_body ();
         `uvm_info (get_type_name(), "Executing post_body", UVM_MEDIUM)
      endtask     
 
      virtual task post_start ();
         `uvm_info (get_type_name (), "Executing post_start", UVM_MEDIUM)
      endtask 
   endclass
endpackage