//=============================================================================
// 1. INTERFACE & DUT
//=============================================================================
interface my_if(input logic clk);
  logic        valid;
  logic [31:0] addr;
  logic [31:0] data;
  logic        rw;
endinterface

module dummy_dut (my_if in_if, my_if out_if);
  // Define a struct to hold the entire packet payload
  typedef struct packed {
    logic        valid;
    logic [31:0] addr;
    logic [31:0] data;
    logic        rw;
  } pipe_t;

  // 10-stage pipeline to create a 10-clock cycle delay
  pipe_t delay_pipe[10];

  always_ff @(posedge in_if.clk) begin
    // Stage 0 samples from the input interface
    delay_pipe[0] <= '{in_if.valid, in_if.addr, in_if.data, in_if.rw};

    // Shift register for stages 1 through 9
    for(int i = 1; i < 10; i++) begin
      delay_pipe[i] <= delay_pipe[i-1];
    end
  end

  // Drive the output interface with the 10th stage (9th index)
  assign out_if.valid = delay_pipe[9].valid;
  assign out_if.addr  = delay_pipe[9].addr;
  assign out_if.data  = delay_pipe[9].data;
  assign out_if.rw    = delay_pipe[9].rw;
endmodule


//=============================================================================
// 2. UVM TESTBENCH COMPONENTS
//=============================================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

// --- Sequence Item ---
class my_packet extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        rw; // 0 = READ, 1 = WRITE

  `uvm_object_utils(my_packet)

  // Constraint: 30% Read, 70% Write
  constraint c_rw_dist { 
    rw dist { 0 := 30, 1 := 70 }; 
  }

  function new(string name = "my_packet");
    super.new(name);
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    my_packet rhs_pkt;
    if (!$cast(rhs_pkt, rhs)) return 0;
    return (super.do_compare(rhs, comparer) &&
            (this.rw   == rhs_pkt.rw)       &&
            (this.addr == rhs_pkt.addr)     &&
            (this.data == rhs_pkt.data));
  endfunction

  virtual function string convert2string();
    string rw_str = (rw == 0) ? "READ" : "WRITE";
    return $sformatf("CMD: %s | ADDR: 'd%0d | DATA: 'h%0h", rw_str, addr, data);
  endfunction
endclass

// --- Sequence ---
class my_sequence extends uvm_sequence #(my_packet);
  `uvm_object_utils(my_sequence)

  function new(string name="my_sequence");
    super.new(name);
  endfunction

  task body();
    // Send exactly 20 packets
    for(int i = 0; i < 20; i++) begin
      req = my_packet::type_id::create("req");
      start_item(req);

      // First 10 packets: Constrain addr < 100
      if (i < 10) begin
        if (!req.randomize() with { addr < 100; }) 
          `uvm_error("SEQ", "Randomization failed!")
      end 
      // Next 10 packets: Standard randomization
      else begin
        if (!req.randomize()) 
          `uvm_error("SEQ", "Randomization failed!")
      end

      finish_item(req);
    end
  endtask
endclass

// --- Driver ---
class my_driver extends uvm_driver #(my_packet);
  `uvm_component_utils(my_driver)
  virtual my_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Could not get vif")
  endfunction

  virtual task run_phase(uvm_phase phase);
    vif.valid <= 0;
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      vif.valid <= 1;
      vif.addr  <= req.addr;
      vif.data  <= req.data;
      vif.rw    <= req.rw;

      @(posedge vif.clk);
      vif.valid <= 0; // De-assert valid after driving
      seq_item_port.item_done();
    end
  endtask
endclass

// --- Monitor ---
class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  virtual my_if vif;
  uvm_analysis_port #(my_packet) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Could not get vif")
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_packet pkt;
    forever begin
      @(posedge vif.clk);
      if (vif.valid) begin
        pkt = my_packet::type_id::create("pkt");
        pkt.addr = vif.addr;
        pkt.data = vif.data;
        pkt.rw   = vif.rw;
        // Broadcast seen packet
        ap.write(pkt);
      end
    end
  endtask
endclass

// --- Agent ---
class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)
  my_driver driver;
  uvm_sequencer #(my_packet) sequencer;
  my_monitor monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = my_monitor::type_id::create("monitor", this);

    // Only build driver and sequencer if agent is ACTIVE
    if (get_is_active() == UVM_ACTIVE) begin
      driver = my_driver::type_id::create("driver", this);
      sequencer = uvm_sequencer#(my_packet)::type_id::create("sequencer", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass

// --- Scoreboard ---
class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)

  uvm_tlm_analysis_fifo #(my_packet) exp_fifo;
  uvm_tlm_analysis_fifo #(my_packet) act_fifo;

  int match_cnt = 0;
  int count_rw = 0;
  int mismatch_cnt = 0;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_fifo = new("exp_fifo", this);
    act_fifo = new("act_fifo", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_packet exp_pkt, act_pkt;
    forever begin
      exp_fifo.get(exp_pkt);
      act_fifo.get(act_pkt);

      if (exp_pkt.rw) begin
              count_rw++;
              `uvm_info("SCBD_RW_COUNT", $sformatf("WRITE! %d", count_rw ), UVM_NONE)
      end

      if (exp_pkt.compare(act_pkt)) begin
        match_cnt++;
        `uvm_info("SCBD_MATCH", $sformatf("Match! %s", act_pkt.convert2string()), UVM_HIGH)
      end else begin
        mismatch_cnt++;
        `uvm_error("SCBD_FAIL", $sformatf("Mismatch!\nEXP: %s\nACT: %s", 
                   exp_pkt.convert2string(), act_pkt.convert2string()))
      end
    end
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCBD", $sformatf("Total Matches: %0d | Mismatches: %0d", match_cnt, mismatch_cnt), UVM_NONE)
    if (mismatch_cnt > 0 || match_cnt != 20) 
      `uvm_error("TEST_FAILED", "Simulation ended with errors or missing packets!")
    else 
      `uvm_info("TEST_PASSED", "All 20 packets matched perfectly!", UVM_NONE)
  endfunction
endclass

// --- Environment ---
class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent in_agent;
  my_agent out_agent;
  my_scoreboard scbd;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create Active agent for input
    in_agent = my_agent::type_id::create("in_agent", this);

    // Create Passive agent for output
    uvm_config_db#(uvm_active_passive_enum)::set(this, "out_agent", "is_active", UVM_PASSIVE);
    out_agent = my_agent::type_id::create("out_agent", this);

    scbd = my_scoreboard::type_id::create("scbd", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    in_agent.monitor.ap.connect(scbd.exp_fifo.analysis_export);
    out_agent.monitor.ap.connect(scbd.act_fifo.analysis_export);
  endfunction
endclass

// --- Test ---
class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  my_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_sequence seq = my_sequence::type_id::create("seq");

    phase.raise_objection(this);

    // Start the sequence on the input agent's sequencer
    seq.start(env.in_agent.sequencer);

    // CRITICAL: Wait for the 10-clock cycle delayed packets 
    // to flush through the RTL pipeline before dropping the objection
    #300; 

    phase.drop_objection(this);
  endtask
endclass


//=============================================================================
// 3. TOP LEVEL MODULE
//=============================================================================
module tb_top;
  logic clk;

  // Clock Generation (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Instantiate Interfaces
  my_if in_if (clk);
  my_if out_if(clk);

  // Instantiate DUT
  dummy_dut dut (
    .in_if (in_if),
    .out_if(out_if)
  );

  initial begin
    // Pass interfaces down to the agents via config_db
    // Notice the hierarchy string points to the respective agents inside the env
    uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.in_agent.*", "vif", in_if);
    uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.out_agent.*", "vif", out_if);

    // Run Test
    run_test("my_test");
  end
endmodule
