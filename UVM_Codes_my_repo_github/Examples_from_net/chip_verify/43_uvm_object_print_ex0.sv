//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM Object Print
// Category : UVM
// Link     : https://www.edaplayground.com/x/3YYD
// Filename : 43_uvm_object_print_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
 
// Author  : Admin, ChipVerify
// Website : www.chipverify.com
 
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
typedef enum {FALSE, TRUE} e_bool;
 
class Packet extends uvm_object;
  rand bit[15:0] 	m_addr;
 
`ifdef UVM_MACRO
  `uvm_object_utils_begin(Packet)
  	`uvm_field_int(m_addr, UVM_DEFAULT)
  `uvm_object_utils_end
 
`else
  `uvm_object_utils(Packet)
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("m_addr", m_addr, $bits(m_addr), UVM_HEX);
  endfunction
`endif
 
  function new(string name = "Packet");
    super.new(name);
  endfunction
 
  virtual function string convert2string();
    string contents;
    contents = $sformatf("m_addr=0x%0h", m_addr);
  endfunction
endclass
 
class Object extends uvm_object;
 
  rand e_bool 				m_bool;
  rand bit[3:0] 			m_mode;
  rand byte 				m_data[4];
  rand shortint 			m_queue[$];
  string 					m_name;
  rand Packet 				m_pkt;
 
  constraint c_queue { m_queue.size() == 3; }
 
  function new(string name = "Object");
    super.new(name);
    m_name = name;
    m_pkt = Packet::type_id::create("m_pkt");
    m_pkt.randomize();
  endfunction
 
  virtual function string convert2string();
    string contents = "";
    $sformat(contents, "%s m_name=%s", contents, m_name);
    $sformat(contents, "%s m_bool=%s", contents, m_bool.name());
    $sformat(contents, "%s m_mode=0x%0h", contents, m_mode);
    foreach(m_data[i]) begin
      $sformat(contents, "%s m_data[%0d]=0x%0h", contents, i, m_data[i]);
    end
    return contents;
  endfunction
 
`ifdef UVM_MACRO  
  `uvm_object_utils_begin(Object)
  	`uvm_field_enum(e_bool, m_bool, UVM_DEFAULT)
  	`uvm_field_int (m_mode, 		UVM_DEFAULT)
  	`uvm_field_sarray_int(m_data, 	UVM_DEFAULT)
  	`uvm_field_queue_int(m_queue, 	UVM_DEFAULT)
  	`uvm_field_string(m_name, 		UVM_DEFAULT)
  	`uvm_field_object(m_pkt, 		UVM_DEFAULT)
  `uvm_object_utils_end
`else
  `uvm_object_utils(Object)
 
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_string("m_bool", m_bool.name());
    printer.print_field_int("m_mode", m_mode, $bits(m_mode), UVM_HEX);
    printer.print_string("m_name", m_name);
  endfunction
`endif
 
endclass
 
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    Object obj = Object::type_id::create("obj");
    obj.randomize();
    obj.print();
    `uvm_info(get_type_name(), $sformatf("Contents: \
%s", obj.sprint()), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("convert2string: \
%s", obj.convert2string()), UVM_LOW)
  endfunction
endclass
 
module tb;
  initial run_test("base_test");
endmodule