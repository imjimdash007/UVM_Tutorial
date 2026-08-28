//------------------------------------------------------------------------
//				DMA RTL - www.verificationguide.com
//------------------------------------------------------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"

module DMA
  #( parameter ADDR_WIDTH = 32,
     parameter DATA_WIDTH = 32 ) (
    input clk,
    input reset,
    
    //control signals
    input [ADDR_WIDTH-1:0]  addr,
    input                   wr_en,
    input                   valid,
    
    //data signals
    input  [DATA_WIDTH-1:0] wdata,
    output [DATA_WIDTH-1:0] rdata
  ); 
  
  logic [DATA_WIDTH-1:0] t_data;
  
  reg [DATA_WIDTH-1:0] intr;
  reg [DATA_WIDTH-1:0] control;
  reg [DATA_WIDTH-1:0] io_address;
  reg [DATA_WIDTH-1:0] mem_address;
  
  //Reset 
  always @(posedge reset) begin //{
    intr        <= 0;
    control     <= 0;
    io_address  <= 0;
    mem_address <= 0;
  end //}

  assign rdata = t_data;

  always @(posedge clk) begin //{
    if (wr_en & valid) begin//{
           if (addr == 32'h400) intr        <= wdata;
      else if (addr == 32'h404) control     <= wdata;
      else if (addr == 32'h408) io_address  <= wdata;
      else if (addr == 32'h40C) mem_address <= wdata;
      $display("Design WR addr %0h Data %0h",addr,wdata);
    end //}
    else if (!wr_en & valid) begin//{
      
           if (addr == 32'h400) t_data = intr         ;
      else if (addr == 32'h404) t_data = control      ;
      else if (addr == 32'h408) t_data = io_address   ;
      else if (addr == 32'h40C) t_data = mem_address  ;
      $display("Design RD addr %0h Data %0h",addr,t_data);
      //rdata = t_data;
    end //}
  end  

endmodule

//-------------------------------------------------------------------------
//						mem_interface - www.verificationguide.com
//-------------------------------------------------------------------------

interface dma_if(input logic clk,reset);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------
  logic [31:0] addr;
  logic        wr_en;
  logic        valid;
  logic [31:0] wdata;
  logic [31:0] rdata;
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output addr;
    output wr_en;
    output valid;
    output wdata;
    input  rdata;  
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input addr;
    input wr_en;
    input valid;
    input wdata;
    input rdata;  
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
  modport MONITOR (clocking monitor_cb,input clk,reset);
  
endinterface

//-------------------------------------------------------------------------
//	Register Class defination - intr
//-------------------------------------------------------------------------
class intr extends uvm_reg;
  `uvm_object_utils(intr)
   
  //---------------------------------------
  // fields instance 
  //--------------------------------------- 
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  //---------------------------------------
  // Constructor 
  //---------------------------------------   
  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE); //32 -> Register Width
  endfunction

  //---------------------------------------
  // build_phase - 
  // 1. Create the fields
  // 2. Configure the fields
  //---------------------------------------  
  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

//-------------------------------------------------------------------------
//	Register Class defination - ctrl
//-------------------------------------------------------------------------
class ctrl extends uvm_reg;
  `uvm_object_utils(ctrl)
   
  //---------------------------------------
  // fields instance 
  //--------------------------------------- 
  rand uvm_reg_field start_dma;
  rand uvm_reg_field w_count;
  rand uvm_reg_field io_mem;
  rand uvm_reg_field reserved;

  //---------------------------------------
  // Constructor 
  //---------------------------------------
  function new (string name = "ctrl");
    super.new(name,32,UVM_NO_COVERAGE); //32 -> Register Width
  endfunction

  //---------------------------------------
  // build_phase - 
  // 1. Create the fields
  // 2. Configure the fields
  //---------------------------------------  
  function void build; 
    start_dma = uvm_reg_field::type_id::create("start_dma");   
    start_dma.configure(.parent(this), 
                        .size(1), 
                        .lsb_pos(0),  
                        .access("RW"),   
                        .volatile(0),  
                        .reset(0),  
                        .has_reset(1),  
                        .is_rand(1),  
                        .individually_accessible(0));  
    
    w_count = uvm_reg_field::type_id::create("w_count");   
    w_count.configure(.parent(this),  
                      .size(8),  
                      .lsb_pos(1),  
                      .access("RW"),   
                      .volatile(0),  
                      .reset(0),  
                      .has_reset(1),  
                      .is_rand(1),  
                      .individually_accessible(0));     
            
    io_mem = uvm_reg_field::type_id::create("io_mem");   
    io_mem.configure(.parent(this),  
                     .size(1),  
                     .lsb_pos(9),  
                     .access("RW"),    
                     .volatile(0),   
                     .reset(0),   
                     .has_reset(1),   
                     .is_rand(1),   
                     .individually_accessible(0));   
            
    reserved = uvm_reg_field::type_id::create("reserved");   
    reserved.configure(.parent(this),  
                       .size(22),  
                       .lsb_pos(10),  
                       .access("RW"),     
                       .volatile(0),    
                       .reset(0),    
                       .has_reset(1),    
                       .is_rand(1),    
                       .individually_accessible(0));        
    endfunction
endclass

//-------------------------------------------------------------------------
//	Register Class defination - io_addr
//-------------------------------------------------------------------------
class io_addr extends uvm_reg;
  `uvm_object_utils(io_addr)
   
  //---------------------------------------
  // fields instance 
  //--------------------------------------- 
  rand uvm_reg_field addr;

  //---------------------------------------
  // Constructor 
  //---------------------------------------   
  function new (string name = "io_addr");
    super.new(name,32,UVM_NO_COVERAGE); //32 -> Register Width
  endfunction

  //---------------------------------------
  // build_phase - 
  // 1. Create the fields
  // 2. Configure the fields
  //---------------------------------------  
  function void build; 
    
    // Create bitfield
    addr = uvm_reg_field::type_id::create("addr");   
    // Configure
    addr.configure(.parent(this), 
                   .size(32), 
                   .lsb_pos(0),  
                   .access("RW"),   
                   .volatile(0),  
                   .reset(0),  
                   .has_reset(1),  
                   .is_rand(1),  
                   .individually_accessible(0));   
    endfunction
endclass

//-------------------------------------------------------------------------
//	Register Class defination - mem_addr
//-------------------------------------------------------------------------
class mem_addr extends uvm_reg;
  `uvm_object_utils(mem_addr)
   
  //---------------------------------------
  // fields instance 
  //--------------------------------------- 
  rand uvm_reg_field addr;

  //---------------------------------------
  // Constructor 
  //---------------------------------------   
  function new (string name = "mem_addr");
    super.new(name,32,UVM_NO_COVERAGE); //32 -> Register Width
  endfunction

  //---------------------------------------
  // build_phase - 
  // 1. Create the fields
  // 2. Configure the fields
  //---------------------------------------  
  function void build; 
    
    // Create bitfield
    addr = uvm_reg_field::type_id::create("addr");   
    // Configure
    addr.configure(.parent(this), 
                   .size(32), 
                   .lsb_pos(0),  
                   .access("RW"),   
                   .volatile(0),  
                   .reset(0),  
                   .has_reset(1),  
                   .is_rand(1),  
                   .individually_accessible(0));   
    endfunction
endclass

//-------------------------------------------------------------------------
//	Register Block Definition
//-------------------------------------------------------------------------
class dma_reg_model extends uvm_reg_block;
  `uvm_object_utils(dma_reg_model)
  
  //---------------------------------------
  // register instances 
  //---------------------------------------
  rand intr 	reg_intr; 
  rand ctrl 	reg_ctrl;
  rand io_addr 	reg_io_addr;
  rand mem_addr reg_mem_addr;
  
  //---------------------------------------
  // Constructor 
  //---------------------------------------
  function new (string name = "");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction

  //---------------------------------------
  // Build Phase 
  //---------------------------------------
  function void build;
    
    //---------------------------------------
    //reg creation
    //---------------------------------------
    reg_intr = intr::type_id::create("reg_intr");
    reg_intr.build();
    reg_intr.configure(this);
    //r0.add_hdl_path_slice("r0", 0, 8);      // name, offset, bitwidth
 
    reg_ctrl = ctrl::type_id::create("reg_ctrl");
    reg_ctrl.build();
    reg_ctrl.configure(this);
    
    reg_io_addr = io_addr::type_id::create("reg_io_addr");
    reg_io_addr.build();
    reg_io_addr.configure(this);
  
    reg_mem_addr = mem_addr::type_id::create("reg_mem_addr");
    reg_mem_addr.build();
    reg_mem_addr.configure(this);
    
    //---------------------------------------
    //Memory map creation and reg map to it
    //---------------------------------------
    default_map = create_map("my_map", 0, 4, UVM_LITTLE_ENDIAN); // name, base, nBytes
    default_map.add_reg(reg_intr	, 'h0, "RW");  // reg, offset, access
    default_map.add_reg(reg_ctrl	, 'h4, "RW");
    default_map.add_reg(reg_io_addr	, 'h8, "RW");
    default_map.add_reg(reg_mem_addr, 'hC, "RW");
    
    lock_model();
  endfunction
endclass
/* This File Contains:
1. Sequence item -> dma_seq_item
2. Sequencer -> dma_sequencer
3. Sequences -> Sequences 
4. driver    -> dma_driver */

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//	 1. dma_seq_item - www.verificationguide.com 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class dma_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit [31:0] addr;
  rand bit       wr_en;
  rand bit [31:0] wdata;
       bit [31:0] rdata;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(dma_seq_item)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(wr_en,UVM_ALL_ON)
    `uvm_field_int(wdata,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "dma_seq_item");
    super.new(name);
  endfunction
  
endclass
//-------------------------------------------------------------------------
//	Register Adapter - dma_adapter
//-------------------------------------------------------------------------
class dma_adapter extends uvm_reg_adapter;
  `uvm_object_utils (dma_adapter)

  //---------------------------------------
  // Constructor 
  //--------------------------------------- 
  function new (string name = "dma_adapter");
      super.new (name);
   endfunction
  
  //---------------------------------------
  // reg2bus method 
  //--------------------------------------- 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    dma_seq_item tx;    
    tx = dma_seq_item::type_id::create("tx");
    
    tx.wr_en = (rw.kind == UVM_WRITE);
    tx.addr  = rw.addr;
    if (tx.wr_en)  tx.wdata = rw.data;
    if (!tx.wr_en) tx.rdata = rw.data;
    //if (tx.wr_en)  $display("[Adapter: reg2bus] WR: Addr=%0h, Data=%0h",tx.addr,tx.wdata);
    //if (!tx.wr_en) $display("[Adapter: reg2bus] RD: Addr=%0h",tx.addr);
    return tx;
  endfunction

  //---------------------------------------
  // bus2reg method 
  //--------------------------------------- 
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    dma_seq_item tx;
    
    assert( $cast(tx, bus_item) )
      else `uvm_fatal("", "A bad thing has just happened in my_adapter")

    rw.kind = tx.wr_en ? UVM_WRITE : UVM_READ;
    rw.addr = tx.addr;
    rw.data = tx.rdata;
    
    //if(rw.kind == UVM_READ) $display("[Adapter: bus2reg] RD: Addr=%0h, Data=%0h",tx.addr,tx.rdata);
    rw.status = UVM_IS_OK;
  endfunction
endclass
//-------------------------------------------------------------------------
//						2. dma_sequencer - www.verificationguide.com
//-------------------------------------------------------------------------

class dma_sequencer extends uvm_sequencer#(dma_seq_item);

  `uvm_component_utils(dma_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//						3. dma_sequence's - www.verificationguide.com
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//=========================================================================
// dma_sequence - random stimulus 
//=========================================================================
class dma_sequence extends uvm_sequence#(dma_seq_item);
  
  `uvm_object_utils(dma_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "dma_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(dma_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
   repeat(2) begin
    req = dma_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass
//=========================================================================

//=========================================================================
// write_sequence - "write" type
//=========================================================================
class write_sequence extends uvm_sequence#(dma_seq_item);
  
  `uvm_object_utils(write_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "write_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.wr_en==1;})
  endtask
endclass
//=========================================================================

//=========================================================================
// read_sequence - "read" type
//=========================================================================
class read_sequence extends uvm_sequence#(dma_seq_item);
  
  `uvm_object_utils(read_sequence)
   
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "read_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    `uvm_do_with(req,{req.wr_en==0;})
  endtask
endclass
//=========================================================================

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//	dma_driver
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

`define DRIV_IF vif.DRIVER.driver_cb

class dma_driver extends uvm_driver #(dma_seq_item);

  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual dma_if vif;
  `uvm_component_utils(dma_driver)
    
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual dma_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase
  
  //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    `DRIV_IF.wr_en <= 0;
    @(posedge vif.DRIVER.clk);
    
    `DRIV_IF.addr <= req.addr;

    `DRIV_IF.valid <= 1;
    `DRIV_IF.wr_en <= req.wr_en;
    if(req.wr_en) begin // write operation
      `DRIV_IF.wdata <= req.wdata;
      @(posedge vif.DRIVER.clk);
    end
    else begin //read operation
      @(posedge vif.DRIVER.clk);
      `DRIV_IF.valid <= 0;
      @(posedge vif.DRIVER.clk);
      req.rdata = `DRIV_IF.rdata;
    end
    `DRIV_IF.valid <= 0;
    
  endtask : drive
endclass : dma_driver

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//	dma_monitor - www.verificationguide.com 
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class dma_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual dma_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(dma_seq_item) item_collected_port;
  
  //---------------------------------------
  // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  dma_seq_item trans_collected;

  `uvm_component_utils(dma_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dma_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
  
  //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.clk);
      wait(vif.monitor_cb.valid);
        trans_collected.addr = vif.monitor_cb.addr;
        trans_collected.wr_en = vif.monitor_cb.wr_en;
      
      if(vif.monitor_cb.wr_en) begin
        trans_collected.wr_en = vif.monitor_cb.wr_en;
        trans_collected.wdata = vif.monitor_cb.wdata;
        @(posedge vif.MONITOR.clk);
      end
      else begin
        @(posedge vif.MONITOR.clk);
        @(posedge vif.MONITOR.clk);
        trans_collected.rdata = vif.monitor_cb.rdata;
      end
	  item_collected_port.write(trans_collected);
      end 
  endtask : run_phase

endclass : dma_monitor

//-------------------------------------------------------------------------
//						dma_agent - www.verificationguide.com 
//-------------------------------------------------------------------------


class dma_agent extends uvm_agent;

  //---------------------------------------
  // component instances
  //---------------------------------------
  dma_driver    driver;
  dma_sequencer sequencer;
  dma_monitor   monitor;

  `uvm_component_utils(dma_agent)
  
  //---------------------------------------
  // constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    monitor = dma_monitor::type_id::create("monitor", this);

    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE) begin
      driver    = dma_driver::type_id::create("driver", this);
      sequencer = dma_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase
  
  //---------------------------------------  
  // connect_phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : dma_agent

class dma_model_env extends uvm_env;
  
  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  dma_agent      dma_agnt;
  
  //---------------------------------------
  // Reg Model and Adapter instance
  //---------------------------------------  
  dma_reg_model  regmodel;   
  dma_adapter    m_adapter;
  
  `uvm_component_utils(dma_model_env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase - create the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dma_agnt = dma_agent::type_id::create("dma_agnt", this);
    
    //---------------------------------------
    // Register model and adapter creation
    //---------------------------------------
    regmodel = dma_reg_model::type_id::create("regmodel", this);
    regmodel.build();
    m_adapter = dma_adapter::type_id::create("m_adapter",, get_full_name());
  endfunction : build_phase
  
  //---------------------------------------
  // connect_phase - connecting regmodel sequencer and adapter with 
  //                             mem agent sequencer and adapter
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
     
    regmodel.default_map.set_sequencer( .sequencer(dma_agnt.sequencer), .adapter(m_adapter) );
    regmodel.default_map.set_base_addr('h400);        
    //regmodel.add_hdl_path("tbench_top.DUT");
  endfunction : connect_phase

endclass : dma_model_env
//-------------------------------------------------------------------------
//	Register Access Sequence
//-------------------------------------------------------------------------
class dma_reg_seq extends uvm_sequence;

  `uvm_object_utils(dma_reg_seq)
  
  dma_reg_model regmodel;
  
  //---------------------------------------
  // Constructor 
  //---------------------------------------    
  function new (string name = ""); 
    super.new(name);    
  endfunction
  
  //---------------------------------------
  // Sequence body 
  //---------------------------------------      
  task body;  
    uvm_status_e   status;
    uvm_reg_data_t incoming;
    bit [31:0]     rdata;
    
    if (starting_phase != null)
      starting_phase.raise_objection(this);
    
    //Write to the Registers
    regmodel.reg_intr.write(status, 32'h1234_1234);
    regmodel.reg_ctrl.write(status, 32'h1234_5678);
    regmodel.reg_io_addr.write(status, 32'h1234_9ABC);
    regmodel.reg_mem_addr.write(status, 32'h1234_DEF0);
    
    //Read from the registers
    regmodel.reg_intr.read(status, rdata);
    regmodel.reg_ctrl.read(status, rdata);
    regmodel.reg_io_addr.read(status, rdata);
    regmodel.reg_mem_addr.read(status, rdata);
      
    if (starting_phase != null)
      starting_phase.drop_objection(this);  
    
  endtask
endclass

/*
1. dma_model_base_test
2. dma_reg_test
*/
//-------------------------------------------------------------------------
//	1. dma_model_base_test - www.verificationguide.com 
//-------------------------------------------------------------------------

class dma_model_base_test extends uvm_test;

  `uvm_component_utils(dma_model_base_test)
  
  //---------------------------------------
  // env instance 
  //--------------------------------------- 
  dma_model_env env;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "dma_model_base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the env
    env = dma_model_env::type_id::create("env", this);
  endfunction : build_phase
  
  //---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------  
  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

  //---------------------------------------
  // end_of_elobaration phase
  //---------------------------------------   
 function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction 

endclass : dma_model_base_test

//-------------------------------------------------------------------------
//	2. dma_reg_test - www.verificationguide.com 
//-------------------------------------------------------------------------

class dma_reg_test extends dma_model_base_test;

  `uvm_component_utils(dma_reg_test)
  
  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  dma_reg_seq reg_seq;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "dma_reg_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create the sequence
    reg_seq = dma_reg_seq::type_id::create("reg_seq");
  endfunction : build_phase
  
  //---------------------------------------
  // run_phase - starting the test
  //---------------------------------------
  task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
      if ( !reg_seq.randomize() ) `uvm_error("", "Randomize failed")
      //Setting sequence in reg_seq
      reg_seq.regmodel       = env.regmodel;
      reg_seq.starting_phase = phase;
      reg_seq.start(env.dma_agnt.sequencer); 
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);
  endtask : run_phase
  
endclass : dma_reg_test

module tbench_top;

  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit reset;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    reset = 1;
    #5 reset =0;
  end
  
  //---------------------------------------
  //interface instance
  //---------------------------------------
  dma_if intf(clk,reset);
  
  //---------------------------------------
  //DUT instance
  //---------------------------------------
  DMA DUT (
    .clk(intf.clk),
    .reset(intf.reset),
    .addr(intf.addr),
    .wr_en(intf.wr_en),
    .valid(intf.valid),
    .wdata(intf.wdata),
    .rdata(intf.rdata)
   );
  
  //---------------------------------------
  //passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual dma_if)::set(uvm_root::get(),"*","vif",intf);
    //enable wave dump
    //$dumpfile("dump.vcd"); 
    //$dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test("dma_reg_test");
  end
  
endmodule