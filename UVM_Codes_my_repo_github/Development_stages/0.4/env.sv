`include "uvm_macros.svh"
import uvm_pkg::*;
`include "driver.sv"
`include "ref_model.sv"
`include "scoreboard.sv"
`include "monitor.sv"

class my_env extends uvm_env;
   `uvm_component_utils(my_env)
   
   ref_model  my_ref_model_1; 
   my_driver  my_driver_1;
   my_sb      my_sb_1;
   my_monitor my_monitor_1;

   function new(string name, uvm_component parent);
     super.new(name, parent);
   endfunction 
   
   virtual function void build_phase(uvm_phase phase); 
      super.build_phase(phase);
      my_ref_model_1 = ref_model::type_id::create("my_ref_model_1", this);
      my_driver_1  = my_driver::type_id::create("my_driver_1", this);
      my_sb_1 = my_sb::type_id::create("my_sb_1",this);
      my_monitor_1 = my_monitor::type_id::create("my_monitor_1",this);
   endfunction 
   
   virtual function void connect_phase(uvm_phase phase);
      my_ref_model_1.ap.connect(my_sb_1.exp);
      my_monitor_1.ap.connect(my_sb_1.act);      
   endfunction // connect_phase

   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #200;
      phase.drop_objection(this); 
   endtask
      
endclass
