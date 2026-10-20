`ifndef REF_MODEL_SV
`define REF_MODEL_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"
import "DPI-C" function int c_counter_predict(int rst, int load, int count_in, int current_count);

class ref_mod extends uvm_component;
   `uvm_component_utils(ref_mod)
   
   uvm_analysis_imp #(my_packet, ref_mod) imp_port;
   uvm_analysis_port #(my_packet) ap_port;

   // Internal registers to preserve state across clock boundaries
   protected bit [3:0] internal_count;
   my_packet out_pack;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
      ap_port  = new("ap_port", this);
      imp_port = new("imp_port", this);
      internal_count = 4'h0; // Initial reset state configuration
   endfunction 
   
   function void write(my_packet pack);
      // 1. SEQUENTIAL STEP: Broadcast the CURRENT latched count state 
      // (This matches the hardware DUT output matching this cycle)
      out_pack = my_packet::type_id::create("out_pack");
      out_pack.rst       = pack.rst;
      out_pack.load      = pack.load;
      out_pack.count_in  = pack.count_in;
      out_pack.count_out = internal_count; 
      
      ap_port.write(out_pack);
      
      `uvm_info("REF_MODEL", $sformatf("BROADCASTING CURRENT: internal_count=%h", internal_count), UVM_LOW)

      // 2. COMBINATIONAL STEP: Compute the NEXT state for the upcoming clock cycle 
      internal_count = c_counter_predict(
                          int'(pack.rst), 
                          int'(pack.load), 
                          int'(pack.count_in), 
                          int'(internal_count)
                       );
      
      `uvm_info("REF_MODEL", $sformatf("NEXT CYCLE VALUE CALCULATED: reset=%d, load=%d, count_in=%h, next_count=%h", pack.rst, pack.load, pack.count_in, internal_count), UVM_LOW)
   endfunction   
endclass

`endif // REF_MODEL_SV
