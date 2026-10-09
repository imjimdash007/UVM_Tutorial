`include "uvm_macros.svh"
import uvm_pkg::*;

class my_driver extends uvm_driver;
   `uvm_component_utils(my_driver)
   virtual m_if vif;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      

      if (!uvm_config_db#(virtual m_if)::get(this, "", "in_vif", vif)) begin
         `uvm_error("CONFIG_ERROR", "Failed to get the interface")
      end 

      // Standard stimulus injection
      vif.rst <= 1'b1;
      #10;
      vif.rst <= 1'b0;
      #100;
      
      phase.drop_objection(this);     
   endtask
endclass   
