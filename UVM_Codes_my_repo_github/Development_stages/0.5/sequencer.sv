`include "uvm_macros.svh"
import uvm_pkg::*;
class my_sequencer extends uvm_sequencer #(my_packet);
  `uvm_component_utils(my_sequencer)
  // Standard constructor for UVM components
  function new(string name = "my_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
endclass : my_sequencer
