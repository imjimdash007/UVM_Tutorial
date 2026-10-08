`include "uvm_macros.svh"
import uvm_pkg::*;

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  bit disable_monitor = 0;
  uvm_analysis_port#(bit [3:0]) ap;
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this); 
  endfunction

  virtual task run_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter vif")
      end
      if(!uvm_config_db#(bit)::get(this, "", "disable_monitor", disable_monitor)) begin
        `uvm_info("CONFIG_INFO", "Disable monitor parameter not found, defaulting to enabled", UVM_HIGH)
      end
      
      if(disable_monitor) begin
         `uvm_info("MONITOR", ">>>> disabling the monitor <<<<", UVM_LOW)
         return;
      end
      
      forever begin
         @(posedge vif.clk); 
         `uvm_info("MONITOR", $sformatf("Sampling DUT Count = %0d (Reset=%b)", vif.count, vif.rst), UVM_HIGH)
         ap.write(vif.count);
      end
   endtask
endclass

