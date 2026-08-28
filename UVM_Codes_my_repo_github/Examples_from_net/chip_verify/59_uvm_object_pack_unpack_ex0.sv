//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM Object Pack/Unpack
// Category : UVM
// Link     : https://www.edaplayground.com/x/pgJ
// Filename : 59_uvm_object_pack_unpack_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class Packet extends uvm_object;
  rand bit [3:0] m_addr;
  rand bit [3:0] m_wdata;
  rand bit [3:0] m_rdata;
  rand bit 		 m_wr;
 
`ifdef UVM_MACRO
  `uvm_object_utils_begin(Packet)
  `uvm_field_int(m_addr, UVM_DEFAULT)
  `uvm_field_int(m_wdata, UVM_DEFAULT)
 
  `uvm_field_int(m_wr, UVM_DEFAULT)
  `uvm_field_int(m_rdata, UVM_DEFAULT)
  `uvm_object_utils_end
`else
 
  `uvm_object_utils(Packet)
 
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("m_addr", m_addr, $bits(m_addr), UVM_HEX);
    printer.print_field_int("m_wdata", m_wdata, $bits(m_wdata), UVM_HEX);
    printer.print_field_int("m_rdata", m_rdata, $bits(m_rdata), UVM_HEX);
    printer.print_field_int("m_wr", m_wr, $bits(m_wr), UVM_HEX);
  endfunction
 
  virtual function void do_pack(uvm_packer packer);
    super.do_pack(packer);
    packer.pack_field_int(m_addr, $bits(m_addr));
    packer.pack_field_int(m_wdata, $bits(m_wdata));
    packer.pack_field_int(m_rdata, $bits(m_rdata));
                          packer.pack_field_int(m_wr, $bits(m_wr));                                            
  endfunction
 
  virtual function void do_unpack(uvm_packer packer);
    super.do_pack(packer);
    m_addr = packer.unpack_field_int($bits(m_addr));
    m_wdata = packer.unpack_field_int($bits(m_wdata));
    m_rdata = packer.unpack_field_int($bits(m_rdata));
                                      m_wr = packer.unpack_field_int($bits(m_wr));                                            
  endfunction
 
`endif
 
  function new(string name = "Packet");
    super.new(name);
  endfunction
endclass
 
class pack_test extends uvm_test;
  `uvm_component_utils(pack_test)
  function new(string name = "pack_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
  bit 	m_bits[];
  byte unsigned	m_bytes[];
  int  unsigned	m_ints[];
 
  virtual function void build_phase(uvm_phase phase);
    Packet m_pkt = Packet::type_id::create("Packet");
    m_pkt.randomize();
    m_pkt.print();
 
    m_pkt.pack(m_bits);
    m_pkt.pack_bytes(m_bytes);
    m_pkt.pack_ints(m_ints); 
    `uvm_info(get_type_name(), $sformatf("m_bits=%p", m_bits), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("m_bytes=%p", m_bytes), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("m_ints=%p", m_ints), UVM_LOW)
  endfunction
endclass
 
class unpack_test extends uvm_test;
  `uvm_component_utils(unpack_test)
  function new(string name = "unpack_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
  bit 	m_bits[];
  byte unsigned	m_bytes[];
  int  unsigned	m_ints[];
 
  int m_val1, m_val2, m_val3;
 
  virtual function void build_phase(uvm_phase phase);
    Packet m_pkt = Packet::type_id::create("Packet");
    Packet m_pkt2 = Packet::type_id::create("Packet");
 
    `uvm_info(get_type_name(), $sformatf("Start pack"), UVM_LOW)
    m_pkt.randomize();
    m_pkt.print();
    m_pkt.pack(m_bits);
    `uvm_info(get_type_name(), $sformatf("packed m_bits=%p", m_bits), UVM_LOW)
 
    m_pkt.randomize();
    m_pkt.print();
    m_pkt.pack_bytes(m_bytes);
    `uvm_info(get_type_name(), $sformatf("packed m_bytes=%p", m_bytes), UVM_LOW)
 
    m_pkt.randomize();
    m_pkt.print();
    m_pkt.pack_ints(m_ints); 
    `uvm_info(get_type_name(), $sformatf("packed m_ints=%p", m_ints), UVM_LOW)
 
    `uvm_info(get_type_name(), $sformatf("Start unpack"), UVM_LOW)
 
    m_val1 = m_pkt2.unpack(m_bits);
    `uvm_info(get_type_name(), $sformatf("unpacked m_val1=0x%0h", m_val1), UVM_LOW)
    m_pkt2.print();
 
    m_val2 = m_pkt2.unpack_bytes(m_bytes);
    `uvm_info(get_type_name(), $sformatf("unpacked m_val2=0x%0h", m_val2), UVM_LOW)
    m_pkt2.print();
 
    m_val3 = m_pkt2.unpack_ints(m_ints);
    `uvm_info(get_type_name(), $sformatf("unpacked m_val3=0x%0h", m_val3), UVM_LOW)
    m_pkt2.print();
  endfunction
endclass
 
module tb;
  initial run_test("unpack_test");
endmodule