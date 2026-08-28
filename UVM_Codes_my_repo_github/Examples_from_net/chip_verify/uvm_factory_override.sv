//--------------------------------------------------
// Copyright (c) 2019 ChipVerify. All Rights Reserved.
// Author   : Admin
// Article  : UVM Factory Override
// Category : UVM
// Link     : https://www.edaplayground.com/x/2XVd
// Filename : 131_uvm_factory_override_ex0.sv
//--------------------------------------------------
 
 
 
 
//----------------------------------
//             Testbench
//----------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;
 
class base_agent extends uvm_agent;
  `uvm_component_utils(base_agent)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
endclass
 
class child_agent extends base_agent;
  `uvm_component_utils(child_agent)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
endclass
 
class base_env extends uvm_env;
  `uvm_component_utils(base_env)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
  base_agent m_agent;
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent = base_agent::type_id::create("m_agent", this);
 
    `uvm_info("AGENT", $sformatf("Factory returned agent of type=%s, path=%s", m_agent.get_type_name(), m_agent.get_full_name()), UVM_LOW)
  endfunction
 
endclass
 
 
class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
 
  base_env m_env;
 
  virtual function void build_phase(uvm_phase phase);
    uvm_factory factory = uvm_factory::get();
    super.build_phase(phase);
 
`ifdef TYPE_BY_TYPE   
    // 1. Override all types by a given type
    set_type_override_by_type(base_agent::get_type(), child_agent::get_type());
 
`elsif INST_BY_TYPE
    // 2. Override a particular instance by its type
    set_inst_override_by_type("m_env.*", base_agent::get_type(), child_agent::get_type());
 
`elsif TYPE_BY_NAME    
    // 3. Override the type by the items name
    factory.set_type_override_by_name("base_agent", "child_agent");
 
`elsif INST_BY_NAME    
    // 4. Override a particular instance by its name
    factory.set_inst_override_by_name("base_agent", "child_agent", {get_full_name(), ".m_env.*"});
`endif
 
//    set_type_override("base_agent", "child_agent");
//    set_inst_override("m_env.m_agent", "base_agent", "child_agent");
    factory.print();
 
    m_env = base_env::type_id::create("m_env", this);
  endfunction
 
endclass
 
 
module tb;
  initial 
    run_test("base_test");
endmodule