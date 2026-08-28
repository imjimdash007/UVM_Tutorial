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
    bit 	  m_bits[];
    byte unsigned m_bytes[];  
    int  unsigned m_ints[];
    rand packet m_pkt;

    function new (string name = "pack_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
        phase.raise_objection(this);
         m_pkt = packet::type_id::create("m_pkt");
         m_pkt.randomize();
         m_pkt.print();

         m_pkt.pack(m_bits);
         m_pkt.pack_bytes(m_bytes);
         m_pkt.pack_ints(m_ints);

          `uvm_info("PACK_TEST", $sformatf("m_bits =%p", m_bits), UVM_LOW)
          `uvm_info("PACK_TEST", $sformatf("m_bytes =%p", m_bytes), UVM_LOW)
	        `uvm_info("PACK_TEST", $sformatf("m_ints =%p", m_ints), UVM_LOW)
        phase.drop_objection(this); 
    endtask
endclass

module tb;
  initial begin
    run_test("pack_test");
  end
endmodule