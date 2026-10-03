`include "uvm_macros.svh"
import uvm_pkg::*;


class my_driver extends uvm_driver;

  `uvm_component_utils(my_driver)
   virtual m_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    // Driver implementation goes here
    phase.raise_objection(this);
    begin
      if (!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter")
      end
      vif.rst <= 1'b1; 
      #10;
      vif.rst <= 1'b0;
      #100;
      //seq_item_port.item_done();  will add in future
    end
    phase.drop_objection(this); 
  endtask
  endclass
