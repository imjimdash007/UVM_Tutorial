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
      // Example: Wait for a transaction from the sequencer
      //uvm_sequence_item item; will add in future 
      //seq_item_port.get_next_item(item);
      
      // Process the item (e.g., drive signals)
      if (!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter")
      end
      vif.rst <= 1'b1; 
      #10;
      vif.rst <= 1'b0;
      #100;
      // Indicate that the item has been processed
      //seq_item_port.item_done();  will add in future
    end
    phase.drop_objection(this); 
  endtask
  endclass