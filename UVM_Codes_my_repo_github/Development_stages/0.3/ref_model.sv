`include "uvm_macros.svh"
import uvm_pkg::*;       

class ref_model extends uvm_component; 
   `uvm_component_utils(ref_model)
   uvm_analysis_port#(bit[3:0]) ap;
   virtual m_if vif;
   bit[3:0] count_exp = 0;
   function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
   endfunction 
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual m_if)::get(this, "", "vif", vif)) begin 
         `uvm_error("REF_MODEL", "Unable to get vif")
      end
   endfunction
   virtual task run_phase(uvm_phase phase);
      forever begin 
         @(posedge vif.clk);
         if(vif.rst) begin
            count_exp = 0;
            `uvm_info("REF_MODEL", $sformatf("count value during reset = %d", count_exp), UVM_LOW) 
            ap.write(count_exp); 
         end else begin
            count_exp++;
            `uvm_info("REF_MODEL", $sformatf("count value = %d", count_exp), UVM_LOW) 
            ap.write(count_exp); 
         end
      end
   endtask
endclass
