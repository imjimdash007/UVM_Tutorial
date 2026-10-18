`include "uvm_macros.svh"
import uvm_pkg::*;

`include "driver.sv"
`include "monitor.sv"
`include "sequencer.sv"

class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)
   my_driver drv1;
   my_monitor mon1;
   my_sequencer seq1;
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction 
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(get_is_active() == UVM_ACTIVE) begin
        drv1 = my_driver::type_id::create("drv1",this);
        seq1  = my_sequencer::type_id::create("seq1",this);
      end 
       mon1 = my_monitor::type_id::create("mon1",this);	 
     endfunction 
   function void connect_phase(uvm_phase phase);
      if(get_is_active() == UVM_ACTIVE) begin	 
         drv1.seq_item_port.connect(seq1.seq_item_export);
      end	 
   endfunction   
endclass    
   
   
   
   
