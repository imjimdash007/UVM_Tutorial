`include "uvm_macros.svh"
import uvm_pkg::*;

class my_packet extends uvm_sequence_item;
  `uvm_object_utils(my_packet) 
  rand bit [3:0] packet;
  function new(string name="my_packet");
     super.new(name);
  endfunction
endclass

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  bit disable_monitor = 0;
  my_packet pkt;
  uvm_analysis_port#(my_packet) ap;

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
         if (!vif.rst) begin
            pkt = my_packet::type_id::create("pkt");
            @(vif.count)
             `uvm_info("TRACK_COUNT", $sformatf("$$$ The current count value is: %d", vif.count), UVM_LOW)
            pkt.packet = vif.count;
            ap.write(pkt);
         end   
      end
   endtask
endclass
