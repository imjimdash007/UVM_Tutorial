`ifndef RAL_MY_DESIGN
`define RAL_MY_DESIGN
 
import uvm_pkg::*;
 
class ral_reg_my_design_rb_control_block_ctl_reg extends uvm_reg;
	rand uvm_reg_field ModuleEn;
	rand uvm_reg_field Speed;
	rand uvm_reg_field LightEn;
	rand uvm_reg_field AutoSwitchOffEn;
 
	function new(string name = "my_design_rb_control_block_ctl_reg");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.ModuleEn = uvm_reg_field::type_id::create("ModuleEn",,get_full_name());
      this.ModuleEn.configure(this, 1, 0, "RW", 0, 1'h0, 1, 0, 0);
      this.Speed = uvm_reg_field::type_id::create("Speed",,get_full_name());
      this.Speed.configure(this, 4, 1, "RW", 0, 4'h6, 1, 0, 0);
      this.LightEn = uvm_reg_field::type_id::create("LightEn",,get_full_name());
      this.LightEn.configure(this, 1, 5, "RW", 0, 1'h1, 1, 0, 0);
      this.AutoSwitchOffEn = uvm_reg_field::type_id::create("AutoSwitchOffEn",,get_full_name());
      this.AutoSwitchOffEn.configure(this, 1, 6, "RW", 0, 1'h0, 1, 0, 0);
   endfunction: build
 
	`uvm_object_utils(ral_reg_my_design_rb_control_block_ctl_reg)
 
endclass : ral_reg_my_design_rb_control_block_ctl_reg
 
 
class ral_reg_my_design_rb_control_block_stat_reg extends uvm_reg;
	rand uvm_reg_field stat_reg;
 
	function new(string name = "my_design_rb_control_block_stat_reg");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.stat_reg = uvm_reg_field::type_id::create("stat_reg",,get_full_name());
      this.stat_reg.configure(this, 32, 0, "RW", 0, 32'hface, 1, 0, 1);
      this.stat_reg.set_reset('h0, "SOFT");
   endfunction: build
 
	`uvm_object_utils(ral_reg_my_design_rb_control_block_stat_reg)
 
endclass : ral_reg_my_design_rb_control_block_stat_reg
 
 
class ral_reg_my_design_rb_control_block_inten_reg extends uvm_reg;
	rand uvm_reg_field inten_reg;
 
	function new(string name = "my_design_rb_control_block_inten_reg");
		super.new(name, 32,build_coverage(UVM_NO_COVERAGE));
	endfunction: new
   virtual function void build();
      this.inten_reg = uvm_reg_field::type_id::create("inten_reg",,get_full_name());
      this.inten_reg.configure(this, 32, 0, "RW", 0, 32'hf000da7a, 1, 0, 1);
      this.inten_reg.set_reset('h0, "SOFT");
   endfunction: build
 
	`uvm_object_utils(ral_reg_my_design_rb_control_block_inten_reg)
 
endclass : ral_reg_my_design_rb_control_block_inten_reg
 
 
class ral_block_my_design_rb_control_block extends uvm_reg_block;
	rand ral_reg_my_design_rb_control_block_ctl_reg ctl_reg;
	rand ral_reg_my_design_rb_control_block_stat_reg stat_reg;
	rand ral_reg_my_design_rb_control_block_inten_reg inten_reg;
	rand uvm_reg_field ctl_reg_ModuleEn;
	rand uvm_reg_field ModuleEn;
	rand uvm_reg_field ctl_reg_Speed;
	rand uvm_reg_field Speed;
	rand uvm_reg_field ctl_reg_LightEn;
	rand uvm_reg_field LightEn;
	rand uvm_reg_field ctl_reg_AutoSwitchOffEn;
	rand uvm_reg_field AutoSwitchOffEn;
	rand uvm_reg_field stat_reg_stat_reg;
	rand uvm_reg_field inten_reg_inten_reg;
 
	function new(string name = "my_design_rb_control_block");
		super.new(name, build_coverage(UVM_NO_COVERAGE));
	endfunction: new
 
   virtual function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.ctl_reg = ral_reg_my_design_rb_control_block_ctl_reg::type_id::create("ctl_reg",,get_full_name());
      this.ctl_reg.configure(this, null, "");
      this.ctl_reg.build();
      this.default_map.add_reg(this.ctl_reg, `UVM_REG_ADDR_WIDTH'h0, "RW", 0);
		this.ctl_reg_ModuleEn = this.ctl_reg.ModuleEn;
		this.ModuleEn = this.ctl_reg.ModuleEn;
		this.ctl_reg_Speed = this.ctl_reg.Speed;
		this.Speed = this.ctl_reg.Speed;
		this.ctl_reg_LightEn = this.ctl_reg.LightEn;
		this.LightEn = this.ctl_reg.LightEn;
		this.ctl_reg_AutoSwitchOffEn = this.ctl_reg.AutoSwitchOffEn;
		this.AutoSwitchOffEn = this.ctl_reg.AutoSwitchOffEn;
      this.stat_reg = ral_reg_my_design_rb_control_block_stat_reg::type_id::create("stat_reg",,get_full_name());
      this.stat_reg.configure(this, null, "");
      this.stat_reg.build();
      this.default_map.add_reg(this.stat_reg, `UVM_REG_ADDR_WIDTH'h4, "RW", 0);
		this.stat_reg_stat_reg = this.stat_reg.stat_reg;
      this.inten_reg = ral_reg_my_design_rb_control_block_inten_reg::type_id::create("inten_reg",,get_full_name());
      this.inten_reg.configure(this, null, "");
      this.inten_reg.build();
      this.default_map.add_reg(this.inten_reg, `UVM_REG_ADDR_WIDTH'h8, "RW", 0);
		this.inten_reg_inten_reg = this.inten_reg.inten_reg;
   endfunction : build
 
	`uvm_object_utils(ral_block_my_design_rb_control_block)
 
endclass : ral_block_my_design_rb_control_block
 
 
class ral_sys_my_design extends uvm_reg_block;
 
   rand ral_block_my_design_rb_control_block rb_control_block;
 
	function new(string name = "my_design");
		super.new(name);
	endfunction: new
 
	function void build();
      this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);
      this.rb_control_block = ral_block_my_design_rb_control_block::type_id::create("rb_control_block",,get_full_name());
      this.rb_control_block.configure(this, "");
      this.rb_control_block.build();
      this.default_map.add_submap(this.rb_control_block.default_map, `UVM_REG_ADDR_WIDTH'h0);
	endfunction : build
 
	`uvm_object_utils(ral_sys_my_design)
endclass : ral_sys_my_design
 
 
 
`endif