
//-- APB 

`include "uvm_macros.svh"
import uvm_pkg::*;
 
class apb_tx extends uvm_object;
   bit [31:0]  addr;
   bit [31:0]  data;
 
   `uvm_object_utils_begin (apb_tx)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
   `uvm_object_utils_end
 
   function new (string name="apb_tx");
      super.new (name);
   endfunction
endclass
 
class apb_driver extends uvm_driver;
   `uvm_component_utils (apb_driver)
   function new (string name="apb_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("APB_DRV", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class apb_monitor extends uvm_monitor;
   `uvm_component_utils (apb_monitor)
   function new (string name="apb_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("APB_MON", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class apb_rw_seq extends uvm_sequence;
   `uvm_object_utils (apb_rw_seq)
   function new (string name = "apb_rw_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RW_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class apb_reset_seq extends uvm_sequence;
   `uvm_object_utils (apb_reset_seq)
   function new (string name = "apb_reset_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RESET_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass

class apb_sequencer extends uvm_sequencer;
 `uvm_sequencer_utils(apb_sequencer)
  function new(string name, uvm_component parent);
     super.new(name,parent);
  endfunction 
endclass

class apb_agent extends uvm_agent;
   `uvm_component_utils (apb_agent)
 
   apb_driver                 m_apb_drv;
   apb_monitor                m_apb_mon;
   apb_sequencer              m_apb_seqr;
 
   function new (string name="apb_agent", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_apb_seqr  = apb_sequencer::type_id::create ("m_apb_seqr", this);
      m_apb_drv   = apb_driver::type_id::create ("m_apb_drv", this);
      m_apb_mon   = apb_monitor::type_id::create ("m_apb_mon", this);
   endfunction
 
   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_apb_drv.seq_item_port.connect (m_apb_seqr.seq_item_export);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("APB_AGNT", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass


//-- SPI --
 
class spi_tx extends uvm_object;
   bit [31:0]  addr;
   bit [31:0]  data;
 
   `uvm_object_utils_begin (spi_tx)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
   `uvm_object_utils_end
 
   function new (string name="spi_tx");
      super.new (name);
   endfunction
endclass
 
class spi_driver extends uvm_driver;
   `uvm_component_utils (spi_driver)
   function new (string name="spi_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_DRV", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class spi_monitor extends uvm_monitor;
   `uvm_component_utils (spi_monitor)
   function new (string name="spi_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_MON", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class spi_rw_seq extends uvm_sequence;
   `uvm_object_utils (spi_rw_seq)
   function new (string name = "spi_rw_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RW_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class spi_reset_seq extends uvm_sequence;
   `uvm_object_utils (spi_reset_seq)
   function new (string name = "spi_reset_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RESET_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class spi_tx_seq extends uvm_sequence;
   `uvm_object_utils (spi_tx_seq)
   function new (string name = "spi_tx_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("tx_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class spi_sequencer extends uvm_sequencer;
 `uvm_sequencer_utils(spi_sequencer)
  function new(string name, uvm_component parent);
     super.new(name,parent);
  endfunction 
endclass

class spi_agent extends uvm_agent;
   `uvm_component_utils (spi_agent)
 
   spi_driver                 m_spi_drv;
   spi_monitor                m_spi_mon;
   spi_sequencer              m_spi_seqr;
 
   function new (string name="spi_agent", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_spi_seqr  = spi_sequencer::type_id::create ("m_spi_seqr", this);
      m_spi_drv   = spi_driver::type_id::create ("m_spi_drv", this);
      m_spi_mon   = spi_monitor::type_id::create ("m_spi_mon", this);
   endfunction
 
   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_spi_drv.seq_item_port.connect (m_spi_seqr.seq_item_export);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("spi_AGNT", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass

//--- WB --

class wb_tx extends uvm_object;
   bit [31:0]  addr;
   bit [31:0]  data;
 
   `uvm_object_utils_begin (wb_tx)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
   `uvm_object_utils_end
 
   function new (string name="wb_tx");
      super.new (name);
   endfunction
endclass
 
class wb_driver extends uvm_driver;
   `uvm_component_utils (wb_driver)
   function new (string name="wb_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_DRV", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class wb_monitor extends uvm_monitor;
   `uvm_component_utils (wb_monitor)
   function new (string name="wb_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_MON", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass
 
class wb_rw_seq extends uvm_sequence;
   `uvm_object_utils (wb_rw_seq)
   function new (string name = "wb_rw_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RW_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass
 
class wb_reset_seq extends uvm_sequence;
   `uvm_object_utils (wb_reset_seq)
   function new (string name = "wb_reset_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("RESET_SEQ", $sformatf ("Starting %s", this.get_type_name()), UVM_MEDIUM)
   endtask
endclass

 class wb_sequencer extends uvm_sequencer;
 `uvm_sequencer_utils(wb_sequencer)
  function new(string name, uvm_component parent);
     super.new(name,parent);
  endfunction 
endclass

class wb_agent extends uvm_agent;
   `uvm_component_utils (wb_agent)
 
   wb_driver                 m_wb_drv;
   wb_monitor                m_wb_mon;
   wb_sequencer              m_wb_seqr;
 
   function new (string name="wb_agent", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_wb_seqr  = wb_sequencer::type_id::create ("m_wb_seqr", this);
      m_wb_drv   = wb_driver::type_id::create ("m_wb_drv", this);
      m_wb_mon   = wb_monitor::type_id::create ("m_wb_mon", this);
   endfunction
 
   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_wb_drv.seq_item_port.connect (m_wb_seqr.seq_item_export);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      `uvm_info ("wb_AGNT", $sformatf ("Starting %s", this.get_type_name()), UVM_FULL)
   endtask
endclass

//--pkg --


 
// This class holds handles to different other sequencers within the environment
class virtual_sequencer extends uvm_sequencer;
   `uvm_component_utils (virtual_sequencer)
   function new (string name = "virtual_sequencer", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   uvm_sequencer  m_apb_seqr;      // APB sequencer handle
    uvm_sequencer  m_wb_seqr;       // WB sequencer handle
    uvm_sequencer  m_spi_seqr;      // SPI sequencer handle
endclass
 // This class defines a virtual sequence that creates and starts multiple other 
// sequences. Each individual sequence will run on their respective sequencer
// We declare that the virtual sequencer can be accessed in this virtual sequence
// as "p_sequencer" and hence all other sequencers become available to this seq
class virt_seq extends uvm_sequence;
   `uvm_object_utils (virt_seq)
   `uvm_declare_p_sequencer (virtual_sequencer)
 
   apb_rw_seq     m_apb_rw_seq;
   wb_reset_seq   m_wb_reset_seq;
   spi_tx_seq     m_spi_tx_seq;
 
   function new (string name = "virt_seq");
      super.new (name);
   endfunction
 
   virtual task body ();
      m_apb_rw_seq = apb_rw_seq::type_id::create ("m_apb_rw_seq");
      m_wb_reset_seq = wb_reset_seq::type_id::create ("m_wb_reset_seq");
      m_spi_tx_seq = spi_tx_seq::type_id::create ("m_spi_tx_seq");
 
      `uvm_info ("VSEQ", "Start of virtual sequence", UVM_MEDIUM)
      fork
        m_wb_reset_seq.start (p_sequencer.m_wb_seqr);
        #20 m_apb_rw_seq.start (p_sequencer.m_apb_seqr);
      join
       #10;
       m_spi_tx_seq.start (p_sequencer.m_spi_seqr);
      `uvm_info ("VSEQ", "End of virtual sequence", UVM_MEDIUM)
   endtask
endclass

class top_env extends uvm_env;
   `uvm_component_utils (top_env)
   function new (string name="top_env", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   apb_agent   m_apb_agent;
   wb_agent    m_wb_agent;
   spi_agent   m_spi_agent;
 
   virtual_sequencer    m_virt_seqr;
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_apb_agent = apb_agent::type_id::create ("m_apb_agent", this);
      m_wb_agent = wb_agent::type_id::create ("m_wb_agent", this);
      m_spi_agent = spi_agent::type_id::create ("m_spi_agent", this);
 
      m_virt_seqr = virtual_sequencer::type_id::create ("m_virt_seq", this);
   endfunction
 
  // Connect actual agent sequencers with the handles inside virtual sequencer
   function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_virt_seqr.m_apb_seqr = m_apb_agent.m_apb_seqr;
      m_virt_seqr.m_wb_seqr = m_wb_agent.m_wb_seqr;
      m_virt_seqr.m_spi_seqr = m_spi_agent.m_spi_seqr;   
   endfunction
endclass
 

 
// A simple test to start our virtual sequence
class base_test extends uvm_test;
   `uvm_component_utils (base_test)
 
   top_env     m_top_env;
   virt_seq    m_virt_seq;
 
   function new (string name, uvm_component parent = null);
      super.new (name, parent);
   endfunction : new
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_top_env  = top_env::type_id::create ("m_top_env", this);
      m_virt_seq = virt_seq::type_id::create ("m_virt_seq");
   endfunction 
 
   virtual function void end_of_elaboration_phase (uvm_phase phase);
      uvm_top.print_topology ();
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      super.main_phase (phase);
      phase.raise_objection (this);
      m_virt_seq.start (m_top_env.m_virt_seqr);
      phase.drop_objection (this);
   endtask
 
   virtual task shutdown_phase (uvm_phase phase);
      super.shutdown_phase (phase);
      `uvm_info ("SHUT", "Shutting down test ...", UVM_MEDIUM)
   endtask
endclass 


//--base tc --

`timescale 1ns/1ps
 
import uvm_pkg::*;
 
module tb_top;
   initial begin
      run_test ("base_test");
   end
 
endmodule



