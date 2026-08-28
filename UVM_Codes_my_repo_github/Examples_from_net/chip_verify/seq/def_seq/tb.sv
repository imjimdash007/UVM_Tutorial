// Author   : Admin (www.chipverify.com)
// Purpose  : Illustrate how to setup a default sequence to be executed 
//            for some sequencer in the testbench
 
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class my_seq extends uvm_sequence;
   `uvm_object_utils (my_seq)
   function new (string name = "my_seq");
      super.new (name);
   endfunction
 
   task body ();
      `uvm_info ("MYSEQ", $sformatf ("Starting seq %s ...", this.get_name()), UVM_MEDIUM)
   endtask
endclass
 
class my_env extends uvm_env;
   `uvm_component_utils (my_env)
 
   uvm_sequencer  tmp_seqr;
 
   function new (string name = "my_env", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      tmp_seqr = uvm_sequencer::type_id::create ("tmp_seqr", this);
   endfunction
endclass
 
class my_test extends uvm_test;
   `uvm_component_utils (my_test)
 
   function new (string name="my_test", uvm_component parent=null);
      super.new (name, parent);
   endfunction
 
   my_env m_env;
 
   function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_env = my_env::type_id::create ("m_env", this);
   endfunction
 
   function void start_of_simulation_phase (uvm_phase phase);
      super.start_of_simulation_phase (phase);
`ifndef NOSEQ
      uvm_config_db#(uvm_object_wrapper)::set(this,"m_env.tmp_seqr.main_phase",
                                       "default_sequence", my_seq::type_id::get());
`endif
   endfunction
endclass
 
module tb_top;
   initial 
      run_test ("my_test");
endmodule