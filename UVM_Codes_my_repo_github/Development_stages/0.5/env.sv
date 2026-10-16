`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"
`include "sequence.sv"
`include "driver.sv"
`include "sequencer.sv"

class my_env extends uvm_env;
   my_driver driver1;
  my_sequencer seq1;
  master_sequence main_seq; 

   
   `uvm_component_utils(my_env)
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
        driver1 = my_driver::type_id::create("driver1", this); 
        seq1 = my_sequencer::type_id::create("seq1", this);
       main_seq = master_sequence::type_id::create("main_seq");
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver1.seq_item_port.connect(seq1.seq_item_export);
   endfunction 
   
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
     `uvm_info("ENV_RUN", "Starting Master Sequence Flow from Env...", UVM_LOW)
      main_seq.start(seq1); 

     #100;
      phase.drop_objection(this);     
   endtask
endclass         
