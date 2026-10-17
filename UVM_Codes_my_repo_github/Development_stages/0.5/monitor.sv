`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  virtual m_if vif;
  uvm_analysis_port#(my_packet) ap;
  my_packet pack; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this); 
  endfunction

  virtual task run_phase(uvm_phase phase);
     if (!uvm_config_db#(virtual m_if)::get(this, "", "in_vif", vif)) begin
        `uvm_error("CONFIG_ERROR", "Failed to get configuration parameter in_vif")
      end

      forever begin
         @(posedge vif.clk);
           if (!vif.rst) begin
               pack = my_packet::type_id::create("pack");
                 pack.rst      = vif.rst;
                 pack.load     = vif.load;
                pack.count_in = vif.count_in;
               ap.write(pack);
             `uvm_info("MONITOR", $sformatf("Sampled: Input=%0d, Rst=%b, Load=%b", vif.count_in, vif.rst, vif.load), UVM_HIGH)
         end
      end
   endtask
endclass

