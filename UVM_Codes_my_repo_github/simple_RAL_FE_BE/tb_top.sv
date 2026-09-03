import uvm_pkg::*;
`include "uvm_macros.svh"

// ============================================================================
// 1. SIMPLE DUT & INTERFACE
// ============================================================================
interface bus_if(input clk, input rstn);
  logic        write;
  logic [31:0] addr;
  logic [31:0] wdata;
  logic [31:0] rdata;
endinterface

module dut(bus_if vif);
  // The physical register we will access
  reg [31:0] ctrl_reg; 

  always @(posedge vif.clk or negedge vif.rstn) begin
    if (!vif.rstn) 
      ctrl_reg <= 32'h0;
    else if (vif.write && vif.addr == 32'h0) 
      ctrl_reg <= vif.wdata;
  end

  always @(*) begin
    if (!vif.write && vif.addr == 32'h0) vif.rdata = ctrl_reg;
    else vif.rdata = 32'h0;
  end
endmodule

// ============================================================================
// 2. UVM SEQUENCE ITEM & AGENT COMPONENTS (Bare minimum)
// ============================================================================
class bus_txn extends uvm_sequence_item;
  rand bit        write;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  `uvm_object_utils_begin(bus_txn)
    `uvm_field_int(write, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="bus_txn"); super.new(name); endfunction
endclass

class bus_driver extends uvm_driver #(bus_txn);
  `uvm_component_utils(bus_driver)
  virtual bus_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  
  task run_phase(uvm_phase phase);
    uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif);
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      vif.addr  <= req.addr;
      vif.write <= req.write;
      if (req.write) vif.wdata <= req.data;
      @(posedge vif.clk);
      if (!req.write) req.data = vif.rdata; // Read capture
      vif.write <= 0;
      seq_item_port.item_done();
    end
  endtask
endclass

class bus_monitor extends uvm_monitor;
  `uvm_component_utils(bus_monitor)
  virtual bus_if vif;
  uvm_analysis_port #(bus_txn) ap;
  function new(string name, uvm_component parent); 
    super.new(name,parent); 
    ap = new("ap", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    bus_txn tr;
    uvm_config_db#(virtual bus_if)::get(this, "", "vif", vif);
    forever begin
      @(posedge vif.clk);
      if (vif.write || (!vif.write && vif.addr == 0)) begin // Very simplified trigger
        tr = bus_txn::type_id::create("tr");
        tr.write = vif.write;
        tr.addr  = vif.addr;
        tr.data  = vif.write ? vif.wdata : vif.rdata;
        ap.write(tr); // Send to Predictor
      end
    end
  endtask
endclass

class bus_agent extends uvm_agent;
  `uvm_component_utils(bus_agent)
  bus_driver driver;
  bus_monitor monitor;
  uvm_sequencer#(bus_txn) sqr;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    driver  = bus_driver::type_id::create("driver", this);
    monitor = bus_monitor::type_id::create("monitor", this);
    sqr     = uvm_sequencer#(bus_txn)::type_id::create("sqr", this);
  endfunction
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass

// ============================================================================
// 3. RAL MODEL (Registers and Block)
// ============================================================================
class ctrl_reg extends uvm_reg;
  `uvm_object_utils(ctrl_reg)
  uvm_reg_field val;
  function new(string name="ctrl_reg"); 
    super.new(name, 32, UVM_NO_COVERAGE); 
  endfunction
  virtual function void build();
    val = uvm_reg_field::type_id::create("val");
    // configure(parent, size, lsb_pos, access, volatile, reset, has_reset, is_rand, indiv_access)
    val.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 0);
  endfunction
endclass

class my_reg_block extends uvm_reg_block;
  `uvm_object_utils(my_reg_block)
  ctrl_reg ctrl;
  function new(string name="my_reg_block"); super.new(name, UVM_NO_COVERAGE); endfunction
  
  virtual function void build();
    ctrl = ctrl_reg::type_id::create("ctrl");
    ctrl.configure(this, null, "");
    ctrl.build();
    
    // BACKDOOR SETUP: Map the register to the HDL path in the DUT
    ctrl.add_hdl_path_slice("ctrl_reg", 0, 32);

    // Create default map: name, base_addr, bus_width (bytes), endianness
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    default_map.add_reg(ctrl, 32'h0, "RW"); // Map ctrl_reg to address 0x0
    
    lock_model();
  endfunction
endclass

// ============================================================================
// 4. ADAPTER (reg2bus and bus2reg)
// ============================================================================
class bus_adapter extends uvm_reg_adapter;
  `uvm_object_utils(bus_adapter)
  function new(string name="bus_adapter"); super.new(name); endfunction
  
  // RAL to Physical Bus
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    bus_txn tr = bus_txn::type_id::create("tr");
    tr.write = (rw.kind == UVM_WRITE);
    tr.addr  = rw.addr;
    tr.data  = rw.data;
    return tr;
  endfunction

  // Physical Bus to RAL (Predictor uses this)
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    bus_txn tr;
    if (!$cast(tr, bus_item)) return;
    rw.kind   = tr.write ? UVM_WRITE : UVM_READ;
    rw.addr   = tr.addr;
    rw.data   = tr.data;
    rw.status = UVM_IS_OK;
  endfunction
endclass

// ============================================================================
// 5. ENVIRONMENT (Connecting Agent, Adapter, and Predictor)
// ============================================================================
class env extends uvm_env;
  `uvm_component_utils(env)
  bus_agent                       agent;
  my_reg_block                    regmodel;
  bus_adapter                     adapter;
  uvm_reg_predictor #(bus_txn)    predictor; // Explicit Predictor

  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  
  function void build_phase(uvm_phase phase);
    agent     = bus_agent::type_id::create("agent", this);
    regmodel  = my_reg_block::type_id::create("regmodel", this);
    adapter   = bus_adapter::type_id::create("adapter");
    predictor = uvm_reg_predictor#(bus_txn)::type_id::create("predictor", this);
    regmodel.build();
  endfunction

  function void connect_phase(uvm_phase phase);
    // Connect Sequencer and Adapter to RAL Map for Frontdoor
    regmodel.default_map.set_sequencer(agent.sqr, adapter);
    
    // Connect Predictor
    predictor.map     = regmodel.default_map;
    predictor.adapter = adapter;
    agent.monitor.ap.connect(predictor.bus_in);
  endfunction
endclass

// ============================================================================
// 6. TEST AND SEQUENCE (Frontdoor & Backdoor execution)
// ============================================================================
class ral_seq extends uvm_sequence;
  `uvm_object_utils(ral_seq)
  my_reg_block regmodel;
  function new(string name="ral_seq"); super.new(name); endfunction
  
  task body();
    uvm_status_e status;
    uvm_reg_data_t rdata;

    // 1. FRONTDOOR WRITE & READ
    `uvm_info("SEQ", "--- STARTING FRONTDOOR ACCESS ---", UVM_NONE)
    regmodel.ctrl.write(status, 32'hAABBCCDD, UVM_FRONTDOOR, .parent(this));
    regmodel.ctrl.read(status, rdata, UVM_FRONTDOOR, .parent(this));
    `uvm_info("SEQ", $sformatf("Frontdoor Read Data: %0h", rdata), UVM_NONE)

    // 2. BACKDOOR WRITE & READ
    `uvm_info("SEQ", "--- STARTING BACKDOOR ACCESS ---", UVM_NONE)
    regmodel.ctrl.write(status, 32'hDEADBEEF, UVM_BACKDOOR, .parent(this));
    regmodel.ctrl.read(status, rdata, UVM_BACKDOOR, .parent(this));
    `uvm_info("SEQ", $sformatf("Backdoor Read Data: %0h", rdata), UVM_NONE)
  endtask
endclass

class ral_test extends uvm_test;
  `uvm_component_utils(ral_test)
  env e;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e", this);
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    // Tell the RAL model where the DUT is instantiated for Backdoor paths
    e.regmodel.set_hdl_path_root("tb_top.dut_inst"); 
  endfunction

  task run_phase(uvm_phase phase);
    ral_seq seq = ral_seq::type_id::create("seq");
    seq.regmodel = e.regmodel;
    
    phase.raise_objection(this);
    seq.start(null); // Sequencer is routed via default_map automatically
    #10;
    phase.drop_objection(this);
  endtask
endclass

// ============================================================================
// 7. TOP MODULE
// ============================================================================
module tb_top;
  bit clk, rstn;
  
  always #5 clk = ~clk;
  
  bus_if vif(clk, rstn);
  dut dut_inst(vif); // Instance name "dut_inst" used in set_hdl_path_root
  
  initial begin
    clk = 0; rstn = 0;
    #15 rstn = 1;
  end
  
  initial begin
    uvm_config_db#(virtual bus_if)::set(null, "*", "vif", vif);
    run_test("ral_test");
  end
endmodule

/*
# 1. Create the working library
vlib work

# 2. Compile the design and testbench 
# (vlog automatically picks up the UVM package in recent Questasim versions)
vlog tb_top.sv

# 3. Simulate the test
# +UVM_TESTNAME is optional here since we hardcoded run_test("ral_test")
vsim -c tb_top -voptargs="+acc" -do "run -all; quit"
*/
