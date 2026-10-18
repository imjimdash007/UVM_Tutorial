`ifndef MONITOR_SV
`define MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  uvm_analysis_port#(my_packet) ap;
  my_packet pack; 

  // Configuration field controlled directly by the parent environment
  bit is_input ; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this); 
  endfunction

  virtual task run_phase(uvm_phase phase);
    if(! uvm_config_db#(bit)::get(this,"","is_input",is_input)) begin
                `uvm_error("CONFIG_ERROR", "Failed to get virtual is_input ")
       end else begin
                   `uvm_info("IS_INPUT", $sformatf("if 1 its input =%b", is_input), UVM_LOW)         
       end
     if (is_input) begin
        if (!uvm_config_db#(virtual m_if)::get(this, "", "in_vif", vif)) begin
            `uvm_error("CONFIG_ERROR", "Failed to get virtual interface hook 'in_vif'")
         end
     end else begin
        if (!uvm_config_db#(virtual m_if)::get(this, "", "out_vif", vif)) begin
            `uvm_error("CONFIG_ERROR", "Failed to get virtual interface hook 'out_vif'")
         end	
     end	
  
   forever begin
   @(posedge vif.clk);
   if (is_input) begin
       // === INPUT MONITOR SAMPLING ===
       // Only sample inputs if reset is clean and inactive
       if (!vif.rst) begin
           pack = my_packet::type_id::create("pack");
           pack.rst       = vif.rst;
           pack.load      = vif.load;
           pack.count_in  = vif.count_in;
           pack.count_out = 4'b0000;
           `uvm_info("MON_IN", $sformatf("Input Agent Sampled: In=%0d, Load=%b", vif.count_in, vif.load), UVM_LOW)
           ap.write(pack);
       end
     end else begin
       // === OUTPUT MONITOR SAMPLING ===
       pack = my_packet::type_id::create("pack");
       pack.rst       = 1'b0;
       pack.load      = 1'b0;
       pack.count_in  = 4'b0000;
       pack.count_out = vif.count_out;
       `uvm_info("MON_OUT", $sformatf("Output Agent Sampled: Count Out=%0d", vif.count_out), UVM_LOW)
       ap.write(pack);
   end
end
   endtask
endclass

`endif 
