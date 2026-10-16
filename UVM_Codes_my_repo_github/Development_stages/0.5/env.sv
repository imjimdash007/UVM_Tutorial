include "uvm_macros.svh"
import uvm_pkg::*;

class my_env extends uvm_env;
   my_driver driver;
   my_sequencer seq;
  `uvm_component_utils(my_env)
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   virtual function void build_phase(uvm_phase phase);
      driver = my_dirver::type_id::create("driver");
      seq = my_sequencer::type_id::create("seq");      
   endfunction
   virtual function void connect_phase(uvm_phase phase);
      driver.seq_port.connect(seq.seq_export);
   endfunction 
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      phase.drop_objection(this);     
   endtask
endclass         
     
   
