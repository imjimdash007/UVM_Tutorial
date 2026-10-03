`include "uvm_macros.svh"
import uvm_pkg::*;

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  bit disable_monitor = 0;
  uvm_analysis_port#(bit [3:0]) ap;
  bit [3:0] last_count = 0;
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this); 
  endfunction

  virtual task run_phase(uvm_phase phase);
      if (!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter vif")
      end
      if(!uvm_config_db#(bit)::get(this, "", "disable_monitor", disable_monitor)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter disable monitor")
      end
      
      if(disable_monitor) begin
         `uvm_info("MONITOR", ">>>> disabling the monitor <<<<", UVM_LOW)
         return;
      end
     forever begin
      @(posedge vif.clk); 
	if (!vif.rst) begin
          if (vif.count != last_count) begin 
	    `uvm_info("TRACK_COUNT", $sformatf("$$ The current count value is: %d", vif.count), UVM_LOW)
            ap.write(vif.count);
            last_count = vif.count; 
          end
       end else begin
         last_count = 0; 
      end
   end
   endtask
endclass
