`include "uvm_macros.svh"
import uvm_pkg::*;
`include "driver.sv"
`include "ref_model.sv"

class my_env extends uvm_env;
   `uvm_component_utils(my_env)
   
   ref_model my_ref_model; 
   my_driver my_driver_1;

   function new(string name, uvm_component parent);
     super.new(name, parent);
   endfunction 
   
   virtual function void build_phase(uvm_phase phase); 
      super.build_phase(phase);
      my_ref_model = ref_model::type_id::create("my_ref_model", this);
      my_driver_1  = my_driver::type_id::create("my_driver_1", this);	 
   endfunction 
   
   virtual function void connect_phase(uvm_phase phase); 
      // Future scoreboard connection hooks go here
   endfunction 
endclass
