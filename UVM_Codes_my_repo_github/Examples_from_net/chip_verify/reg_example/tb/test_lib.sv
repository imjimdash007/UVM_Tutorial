`include "uvm_macros.svh"
import uvm_pkg::*;
`include "my_env.sv"
 
//--------------------------------- base_test {{{1 -----------------------------------
class base_test extends uvm_test;
   `uvm_component_utils (base_test)
 
   my_env         m_env;
   my_sequence    m_seq;
   reset_seq      m_reset_seq;
 
   function new (string name = "base_test", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_env = my_env::type_id::create ("m_env", this);
      m_seq = my_sequence::type_id::create ("m_seq", this);
      m_reset_seq = reset_seq::type_id::create ("m_reset_seq", this);
   endfunction
 
   virtual task reset_phase (uvm_phase phase);
      super.reset_phase (phase);
      phase.raise_objection (this);
      m_reset_seq.start (m_env.m_agent.m_seqr);
      phase.drop_objection (this);
   endtask
 
   virtual task main_phase (uvm_phase phase);
      phase.raise_objection (this);
      m_seq.start (m_env.m_agent.m_seqr);
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test1 {{{1 -----------------------------------
class reg_test1 extends base_test;
   `uvm_component_utils (reg_test1)
   function new (string name="reg_test1", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
      `uvm_info ("INFO", "This test simply checks the register model desired/mirrored values after reset", UVM_MEDIUM)
 
      `uvm_info ("Reg", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.get ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("has_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.has_reset ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("get_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_reset ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_mirrored_value ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.needs_update ()), UVM_MEDIUM)
 
      // Check for fields
      `uvm_info ("Field:Speed", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get ()), UVM_MEDIUM)
      `uvm_info ("Field:Speed", $sformatf ("has_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.has_reset ()), UVM_MEDIUM)
      `uvm_info ("Field:Speed", $sformatf ("get_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get_reset ()), UVM_MEDIUM)
      `uvm_info ("Field:Speed", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get_mirrored_value ()), UVM_MEDIUM)
      `uvm_info ("Field:Speed", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.Speed.needs_update ()), UVM_MEDIUM)
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test2 {{{1 -----------------------------------
class reg_test2 extends base_test;
   `uvm_component_utils (reg_test2)
   function new (string name="reg_test2", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
      `uvm_info ("INFO", "This test first mirrors the value in design, then checks ral model values", UVM_MEDIUM)
 
      `uvm_info ("Reg", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.get ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("has_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.has_reset ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("get_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_reset ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_mirrored_value ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.needs_update ()), UVM_MEDIUM);
 
      m_ral_model.rb_control_block.ctl_reg.mirror (status);
 
      `uvm_info ("Reg", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.get ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_mirrored_value ()), UVM_MEDIUM);
      `uvm_info ("Reg", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.needs_update ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get_mirrored_value ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.Speed.needs_update ()), UVM_MEDIUM);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test3 {{{1 -----------------------------------
class reg_test3 extends base_test;
   `uvm_component_utils (reg_test3)
   function new (string name="reg_test3", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
      `uvm_info ("INFO", "This test sets a desired value and uses update()", UVM_MEDIUM)
 
      // Now set a value, check needs update
      m_ral_model.rb_control_block.ctl_reg.Speed.set ('ha);
      `uvm_info ("Field:Speed", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get_mirrored_value ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.Speed.needs_update ()), UVM_MEDIUM);
      m_ral_model.rb_control_block.ctl_reg.update (status);
 
      `uvm_info ("Field:Speed", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.Speed.get_mirrored_value ()), UVM_MEDIUM);
      `uvm_info ("Field:Speed", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.Speed.needs_update ()), UVM_MEDIUM);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test4 {{{1 -----------------------------------
class reg_test4 extends base_test;
   `uvm_component_utils (reg_test4)
   function new (string name="reg_test4", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      uvm_reg_hw_reset_seq    m_reg_reset_seq = uvm_reg_hw_reset_seq::type_id::create ("m_reg_reset_seq", this);      
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      m_reg_reset_seq.model = m_ral_model.rb_control_block;
      m_reg_reset_seq.start (null);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test5 {{{1 -----------------------------------
class reg_test5 extends base_test;
   `uvm_component_utils (reg_test5)
   function new (string name="reg_test5", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      m_ral_model.rb_control_block.reset();
 
      `uvm_info ("Reg", $sformatf ("get=0x%0h", m_ral_model.rb_control_block.ctl_reg.get ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("has_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.has_reset ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("get_reset=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_reset ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("get_mirrored_value=0x%0h", m_ral_model.rb_control_block.ctl_reg.get_mirrored_value ()), UVM_MEDIUM)
      `uvm_info ("Reg", $sformatf ("needs_update=0x%0h
", m_ral_model.rb_control_block.ctl_reg.needs_update ()), UVM_MEDIUM)
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test6 {{{1 -----------------------------------
class reg_test6 extends base_test;
   `uvm_component_utils (reg_test6)
   function new (string name="reg_test6", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      uvm_reg_single_bit_bash_seq    m_single_reg_bash_seq = uvm_reg_single_bit_bash_seq::type_id::create ("m_reg_bash_seq", this);
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      m_single_reg_bash_seq.rg = m_ral_model.rb_control_block.ctl_reg;
      m_single_reg_bash_seq.start (null);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test7 {{{1 -----------------------------------
class reg_test7 extends base_test;
   `uvm_component_utils (reg_test7)
   function new (string name="reg_test7", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      uvm_reg_bit_bash_seq    m_reg_bash_seq = uvm_reg_bit_bash_seq::type_id::create ("m_reg_bash_seq", this);
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      m_reg_bash_seq.model = m_ral_model.rb_control_block;
      m_reg_bash_seq.start (null);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test8 {{{1 -----------------------------------
class reg_test8 extends base_test;
   `uvm_component_utils (reg_test8)
   function new (string name="reg_test8", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
      uvm_reg_single_access_seq    m_reg_single_access_seq = uvm_reg_single_access_seq::type_id::create ("m_reg_single_access_seq", this);
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      m_reg_single_access_seq.rg = m_ral_model.rb_control_block.ctl_reg;
      m_reg_single_access_seq.start (null);
 
      phase.drop_objection (this);
   endtask
endclass
 
//--------------------------------- reg_test9 {{{1 -----------------------------------
/* // under development
class reg_test9 extends base_test;
   `uvm_component_utils (reg_test9)
   function new (string name="reg_test9", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   my_reg_cbs  m_cb;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_cb = my_reg_cbs::type_id::create ("m_cb");
   endfunction
 
   virtual task main_phase (uvm_phase phase);
      int rdata;
      ral_sys_my_design    m_ral_model;
      uvm_status_e   status;
 
 
      phase.raise_objection (this);
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
 
      uvm_reg_cb::add (m_ral_model.rb_control_block.ctl_reg, m_cb); 
      m_ral_model.rb_control_block.ctl_reg.write (status, 32'ha0a0_5050);
      phase.drop_objection (this);
   endtask
endclass
*/