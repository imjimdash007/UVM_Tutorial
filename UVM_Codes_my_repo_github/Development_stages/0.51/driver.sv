`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class my_driver extends uvm_driver #(my_packet); // Best practice: parameterize the class
   `uvm_component_utils(my_driver)
    virtual m_if vif;
    my_packet trans;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   virtual task run_phase(uvm_phase phase);
     if (!uvm_config_db#(virtual m_if)::get(this, "", "in_vif", vif)) begin
         `uvm_error("CONFIG_ERROR", "Failed to get the interface")
      end 
      vif.rst      <= 1'b1;
      vif.load     <= 1'b0;
      vif.count_in <= 4'b0000;
      @(posedge vif.clk);
      vif.rst      <= 1'b0;
       forever begin
         seq_item_port.get_next_item(trans);
          @(posedge vif.clk);
         vif.rst      <= trans.rst;
         vif.load     <= trans.load;
         vif.count_in <= trans.count_in;
         seq_item_port.item_done();
      end
   endtask
endclass   
