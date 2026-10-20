`ifndef APB_FSM_REG_MODEL__SV
`define APB_FSM_REG_MODEL__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class reg_reg0 extends uvm_reg;
    `uvm_object_utils(reg_reg0)
    rand uvm_reg_field ctrl;

    function new(string name = "reg_reg0");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.ctrl = uvm_reg_field::type_id::create("ctrl");
        this.ctrl.configure(
            .parent(this),
            .size(4),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(4'h1),
            .has_reset(1),
            .rand_ise(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_reg1 extends uvm_reg;
    `uvm_object_utils(reg_reg1)
    rand uvm_reg_field ctrl;

    function new(string name = "reg_reg1");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.ctrl = uvm_reg_field::type_id::create("ctrl");
        this.ctrl.configure(
            .parent(this),
            .size(4),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(4'h1),
            .has_reset(1),
            .rand_ise(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_reg2 extends uvm_reg;
    `uvm_object_utils(reg_reg2)
    rand uvm_reg_field ctrl;

    function new(string name = "reg_reg2");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.ctrl = uvm_reg_field::type_id::create("ctrl");
        this.ctrl.configure(
            .parent(this),
            .size(4),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(4'h1),
            .has_reset(1),
            .rand_ise(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_reg3 extends uvm_reg;
    `uvm_object_utils(reg_reg3)
    rand uvm_reg_field ctrl;

    function new(string name = "reg_reg3");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.ctrl = uvm_reg_field::type_id::create("ctrl");
        this.ctrl.configure(
            .parent(this),
            .size(4),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(4'h1),
            .has_reset(1),
            .rand_ise(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_status_reg extends uvm_reg;
    `uvm_object_utils(reg_status_reg)
    rand uvm_reg_field state;

    function new(string name = "reg_status_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.state = uvm_reg_field::type_id::create("state");
        this.state.configure(
            .parent(this),
            .size(4),
            .lsb_pos(0),
            .access("RO"),
            .volatile(1),
            .reset(4'h1),
            .has_reset(1),
            .rand_ise(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class apb_fsm_reg_block extends uvm_reg_block;
    `uvm_object_utils(apb_fsm_reg_block)
    rand reg_reg0 reg0;
    rand reg_reg1 reg1;
    rand reg_reg2 reg2;
    rand reg_reg3 reg3;
    rand reg_status_reg status_reg;

    function new(string name = "apb_fsm_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        this.default_map = create_map("default_map", 'h0, 4, UVM_LITTLE_ENDIAN, 0);

        this.reg0 = reg_reg0::type_id::create("reg0");
        this.reg0.configure(this, null, "");
        this.reg0.build();
        this.default_map.add_reg(this.reg0, 0x00, "RW");

        this.reg1 = reg_reg1::type_id::create("reg1");
        this.reg1.configure(this, null, "");
        this.reg1.build();
        this.default_map.add_reg(this.reg1, 0x04, "RW");

        this.reg2 = reg_reg2::type_id::create("reg2");
        this.reg2.configure(this, null, "");
        this.reg2.build();
        this.default_map.add_reg(this.reg2, 0x08, "RW");

        this.reg3 = reg_reg3::type_id::create("reg3");
        this.reg3.configure(this, null, "");
        this.reg3.build();
        this.default_map.add_reg(this.reg3, 0x0C, "RW");

        this.status_reg = reg_status_reg::type_id::create("status_reg");
        this.status_reg.configure(this, null, "");
        this.status_reg.build();
        this.default_map.add_reg(this.status_reg, 0x10, "RO");

        lock_model();
    endfunction
endclass

`endif // APB_FSM_REG_MODEL__SV
