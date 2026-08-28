//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM Object Copy/Clone
// Category : UVM
// Link     : https://www.edaplayground.com/x/47fy
// Filename : 265_uvm_object_copy_clone_ex0.sv
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
 
  virtual function string convert2string();
    string contents;
    contents = $sformatf("m_addr=0x%0h", m_addr);
  endfunction
 
`ifdef UVM_MACRO
  `uvm_object_utils_begin(Packet)
  	`uvm_field_int(m_addr, UVM_DEFAULT)
  `uvm_object_utils_end
 
`else
  `uvm_object_utils(Packet)
  virtual function void do_copy(uvm_object rhs);
    Packet _pkt;
    super.do_copy(rhs);
    $cast(_pkt, rhs);
   	m_addr = _pkt.m_addr;
    `uvm_info(get_name(), "In Packet::do_copy()", UVM_LOW)
  endfunction
`endif
 
  function new(string name = "Packet");
    super.new(name);
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
 
  // This task is used to print contents
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
 
  // Define this macro "UVM_MACRO" during compilation to enable automation
`ifdef UVM_MACRO  
  `uvm_object_utils_begin(Object)
  	`uvm_field_enum(e_bool, m_bool, UVM_DEFAULT)
  	`uvm_field_int (m_mode, 		UVM_DEFAULT)
  	`uvm_field_sarray_int(m_data, 	UVM_DEFAULT)
  	`uvm_field_queue_int(m_queue, 	UVM_DEFAULT)
  	`uvm_field_string(m_name, 		UVM_DEFAULT)
  	`uvm_field_object(m_pkt, 		UVM_DEFAULT)
  `uvm_object_utils_end
 
  // If automation is not enabled, then use "do_copy" method
`else
  `uvm_object_utils(Object)
 
  // "rhs" does not contain m_bool, m_mode, etc since its a parent
  // handle. So cast into child data type and access using child handle
  // Copy each field from the casted handle into local variables
  virtual function void do_copy(uvm_object rhs);
    Object _obj;
    super.do_copy(rhs);
    $cast(_obj, rhs);
    m_bool 	= _obj.m_bool;
    m_mode 	= _obj.m_mode;
    m_data 	= _obj.m_data;
    m_queue = _obj.m_queue;
    m_name 	= _obj.m_name;
    m_pkt.copy(_obj.m_pkt);
    `uvm_info(get_name(), "In Object::do_copy()", UVM_LOW)
  endfunction
`endif
endclass
 
// Create two objects "obj1" and "obj2", randomize both and print their contents
// Note that both have different values for each variables. Now copy contents in 
// "obj1" into "obj2" and print "obj2". See that contents in "obj1" was indeed
// copied into "obj2"
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    Object obj1 = Object::type_id::create("obj1");
    Object obj2 = Object::type_id::create("obj2");
    obj1.randomize();
    `uvm_info("TEST", $sformatf("Obj1.print: %s", obj1.convert2string()), UVM_LOW)
    obj2.randomize();
    `uvm_info("TEST", $sformatf("Obj2.print: %s", obj2.convert2string()), UVM_LOW)
 
    obj2.copy(obj1);
    `uvm_info("TEST", "After copy", UVM_LOW)
    `uvm_info("TEST", $sformatf("Obj2.print: %s", obj2.convert2string()), UVM_LOW)
  endfunction
endclass
 
 
// Testbench module which starts base test
module tb;
  initial run_test("base_test");
endmodule