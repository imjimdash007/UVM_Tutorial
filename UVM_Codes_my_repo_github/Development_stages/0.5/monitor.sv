`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  uvm_analysis_port#(my_packet) ap;
  my_packet pack; 

  // CONFIGURATION PARAMETER: Controls monitor mode
  bit is_input = 1; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this); 
  endfunction

  virtual task run_phase(uvm_phase phase);
     if (!uvm_config_db#(virtual m_if)::get(this, "", "in_vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get virtual interface hook")
     end
     
     uvm_config_db#(bit)::get(this, "", "is_input", is_input);

     forever begin
         @(posedge vif.clk);
            if (!vif.rst) begin
             pack = my_packet::type_id::create("pack");
             if (is_input) begin
                 // === INPUT MONITOR MODE ===
                 pack.rst      = vif.rst;
                 pack.load     = vif.load;
                 pack.count_in = vif.count_in;
                 `uvm_info("MON_IN", $sformatf("Input Agent Sampled: In=%0d, Load=%b", vif.count_in, vif.load), UVM_HIGH)
             end else begin
                 // === OUTPUT MONITOR MODE ===
                 pack.count_out = vif.count_out;
                 `uvm_info("MON_OUT", $sformatf("Output Agent Sampled: Count Out=%0d", vif.count_out), UVM_LOW)
             end
               ap.write(pack);
         end
      end
   endtask
endclass

