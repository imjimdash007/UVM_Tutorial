//For Srikanth

import uvm_pkg::*;
`include "uvm_macros.svh"

// 1. Simple Interface
interface my_if(input logic clk);
  logic [7:0] data;
endinterface

// 2. Driver that needs the interface
class my_driver extends uvm_driver;
  `uvm_component_utils(my_driver)
  
  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //correction 
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif)) begin
       `uvm_fatal("NOVIF", "Could not get vif from config_db!") 
    end
    // INTENTIONAL BUG: 
    // We are trying to get "vif_wrong_name", but the top module sets it as "vif".
    // We cast the return to void so the simulation continues into the run_phase
    // to intentionally cause a null-object crash.
   //    void'(uvm_config_db#(virtual my_if)::get(this, "", "vif_wrong_name", vif));
   // After doing debug by enabling  +UVM_CONFIG_DB_TRACE 
   // # UVM_INFO verilog_src/uvm-1.1d/src/base/uvm_resource_db.svh(121) @ 0: reporter [CFGDB/SET] Configuration '*.vif' (type virtual my_if) set by  = (virtual my_if) /tb_top/intf     
     
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("DRV", "Attempting to drive virtual interface...", UVM_LOW)
    
    #10;
    // CRASH HAPPENS HERE: vif is null!
    vif.data <= 8'hFF;
     //# ** Fatal: (SIGSEGV) Bad handle or reference.
     //#    Time: 10 ns  Iteration: 0  Process: /uvm_pkg::uvm_task_phase::execute/#FORK#137(#ublk#21518115#137)_7feff02a5c2 File: /home/aj/Questasim/questasim/linux_x86_64/../verilog_src/uvm-1.1d/src/base/uvm_common_phases.svh
     //# Fatal error in Task tb_top_sv_unit/my_driver::run_phase at tb_top.sv line 37     
    
    phase.drop_objection(this);
  endtask
endclass

// 3. Simple Test
class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  my_driver drv;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = my_driver::type_id::create("drv", this);
  endfunction
endclass

// 4. Top-level module
module tb_top;
  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  my_if intf(clk);

  initial begin
    // Set the interface in the database with the field name "vif"
    uvm_config_db#(virtual my_if)::set(null, "*", "vif", intf);
    run_test("my_test");
  end
endmodule
