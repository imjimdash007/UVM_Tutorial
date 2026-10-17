`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class ref_mod extends uvm_component;
  `uvm_component_utils(ref_mod)
   uvm_analysis_import#(packet,ref_mod)  imp_port;
   uvm_analysis_port#(bit [3:0]) ap_port;
   my_packet pack
   protected bit [3:0] internal_count;
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap_port = new("ap_port", this);
     imp_port = new("imp_port",this);
  endfunction 
   virtual task run_phase(uvm_phase);
      forever begin
       	  pack=
      end	 
   endtask 
   
      
