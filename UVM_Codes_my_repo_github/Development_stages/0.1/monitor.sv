`include "uvm_macros.svh"
import uvm_pkg::*;


class my_monitor extends uvm_monitor;

  `uvm_component_utils(my_monitor)
   virtual m_if vif;
   bit disable_monitor = 0;
   

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter")
      end
      if(!uvm_config_db#(bit)::get(this, "", "disable_monitor", disable_monitor)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter disable monitor")
      end
      
      if(disable_monitor) begin
	 `uvm_info("MONITOR", ">>>> disabling the monitor <<<<", UVM_LOW)
	 return;
      end
     forever begin
       @(vif.count) begin
	   if (!vif.rst) begin
	      `uvm_info("TRACK_COUNT", $sformatf("$$$ The current count value is: %d", vif.count), UVM_LOW)
	   end   
       end
     end
   endtask
 endclass
