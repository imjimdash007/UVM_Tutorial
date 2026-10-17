`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"

class ref_mod extends uvm_component;
  `uvm_component_utils(ref_mod)
   uvm_analysis_imp   #(my_packet,ref_mod)  imp_port;
   uvm_analysis_port #(bit [3:0]) ap_port;

   protected bit [3:0] internal_count;
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap_port = new("ap_port", this);
     imp_port = new("imp_port",this);
  endfunction 
   
   function void write( my_packet pack);
      if(pack.rst) begin
	 internal_count = 4'h0;
      end else if(pack.load) begin
	 internal_count = pack.count_in;
      end else begin
	 internal_count = internal_count + 1;
      end
      ap_port.write(internal_count);
      `uvm_info("REF_MODEL",$sformatf("reset=%d,load=%d,count_in=%h,internal_count=%h",pack.rst,pack.load,pack.count_in,internal_count),UVM_LOW)
   endfunction   
endclass
   
  
