//Simple example of pack 
import uvm_pkg::*;
`include "uvm_macros.svh"

class packet extends uvm_object;
  rand bit [3:0] m_addr;
  rand bit [3:0] m_wdata;
  rand bit [3:0] m_rdata;
  rand bit [3:0] m_wr;

  `uvm_object_utils_begin(packet)
    `uvm_field_int(m_addr, UVM_DEFAULT)
    `uvm_field_int(m_wdata, UVM_DEFAULT)
    `uvm_field_int(m_rdata, UVM_DEFAULT)
    `uvm_field_int(m_wr, UVM_DEFAULT)
  `uvm_object_utils_end

 function new (string name = "packet");
   super.new(name);
 endfunction
endclass

class pack_test extends uvm_test;
 `uvm_component_utils(pack_test)
    rand packet pkt;
    rand bit [3:0] addr;
    rand bit [3:0] wdata;
    rand bit [3:0] rdata;
    rand bit [3:0] wr;
    
    function new (string name = "pack_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
        phase.raise_objection(this);
         pkt = packet::type_id::create("pkt");
         pkt.randomize();
         addr = pkt.m_addr;
         wdata = pkt.m_wdata;
         rdata = pkt.m_rdata;
         wr = pkt.m_wr;
         `uvm_info("PACK_TEST", $sformatf("addr: %0d, wdata: %0d, rdata: %0d, wr: %0d", addr, wdata, rdata, wr), UVM_LOW)
         `uvm_info("PACK_TEST", $sformatf("pkt.m_addr: %0d, pkt.m_wdata: %0d, pkt.m_rdata: %0d, pkt.m_wr: %0d", pkt.m_addr, pkt.m_wdata, pkt.m_rdata, pkt.m_wr), UVM_LOW)
        phase.drop_objection(this); 
    endtask
endclass

module tb;
  initial begin
    run_test("pack_test");
  end
endmodule