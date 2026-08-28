import uvm_pkg::*;
`include "uvm_macros.svh"
typedef enum {PUSH_A,PUSH_B,ADD,SUB,MUL,DIV,POP_C} inst_e;

//-----Packet/Transaction-----
class my_seq_item extends uvm_sequence_item;
  rand inst_e inst;
  `uvm_object_utils_begin(my_seq_item)
    `uvm_field_enum(inst_e,inst, UVM_DEFAULT)
  `uvm_object_utils_end

  function new (string name = "my_seq_item");
    super.new(name);
  endfunction : new

  function string convert2string();
    convert2string = $sformatf("inst:%s", inst.name());
  endfunction : convert2string
endclass : my_seq_item

//-----Sequencer-----
class my_sequencer extends uvm_sequencer #(my_seq_item);
  `uvm_sequencer_utils(my_sequencer)

  function new (string name = "my_sequencer", uvm_component parent = null);
    super.new(name, parent);
    `uvm_update_sequence_lib_and_item(my_seq_item)
  endfunction : new
endclass : my_sequencer

//-----Driver-----
class my_driver extends uvm_driver #(my_seq_item);
  `uvm_component_utils(my_driver)

  function new (string name = "my_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  task run_phase (uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      $display($time," Driving pkt %s", req.convert2string());
      #10;
      seq_item_port.item_done();
    end
  endtask : run_phase
endclass : my_driver

//-----Agent-----
class my_agent extends uvm_agent;
  my_sequencer sqr;
  my_driver    drv;
  `uvm_component_utils(my_agent)

  function new (string name = "my_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    sqr = my_sequencer::type_id::create("sqr", this);
    drv = my_driver::type_id::create("drv", this);
  endfunction : build_phase

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction : connect_phase
endclass : my_agent

//-----seq_a-----
class seq_a extends uvm_sequence #(my_seq_item);
  my_seq_item req;
  `uvm_object_utils(seq_a)

  function new(string name="seq_a");
    super.new(name);
  endfunction : new
  
  virtual task body();
    repeat(4) begin
      `uvm_do_with(req, { inst == PUSH_A; });
    end
  endtask : body
endclass : seq_a

//-----seq_b-----
class seq_b extends uvm_sequence #(my_seq_item);
  my_seq_item req;
  `uvm_object_utils(seq_b)
 
  function new(string name="seq_b");
    super.new(name);
  endfunction : new
  
  virtual task body();
    //lock(); // or lock(m_sequencer);
    repeat(4) begin
      `uvm_do_with(req, { inst == PUSH_B; });
    end
 //   unlock(); // or unlock(m_sequencer);
  endtask : body
endclass : seq_b

//-----seq_c-----
class seq_c extends uvm_sequence #(my_seq_item);
  my_seq_item req;
  `uvm_object_utils(seq_c)
 
  function new(string name="seq_c");
    super.new(name);
  endfunction : new

  virtual task body();
    repeat(4) begin
      `uvm_do_with(req, { inst == POP_C; });
    end
  endtask : body
endclass  : seq_c

//-----Virtual sequence-----
class parallel_sequence extends uvm_sequence #(my_seq_item);
  seq_a s_a;
  seq_b s_b;
  seq_c s_c;
  `uvm_object_utils(parallel_sequence)
 
  function new(string name="parallel_sequence");
    super.new(name);
  endfunction : new
  
  virtual task body();
    s_a = seq_a::type_id::create("s_a");
    s_b = seq_b::type_id::create("s_b");
    s_c = seq_c::type_id::create("s_c");
    fork
      s_a.start(m_sequencer);
      s_c.start(m_sequencer);
      s_b.start(m_sequencer);      
    join
  endtask : body
endclass  : parallel_sequence

//-----Test-----
class my_test extends uvm_test;
  my_agent agent;
  `uvm_component_utils(my_test)

  function new (string name = "my_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    seq_a s_a = seq_a::type_id::create("s_a");
    phase.raise_objection(this);
    s_a.start(agent.sqr);
    phase.drop_objection(this);
  endtask : run_phase
endclass : my_test

module top();
  initial begin
    run_test("my_test");
  end
endmodule : top