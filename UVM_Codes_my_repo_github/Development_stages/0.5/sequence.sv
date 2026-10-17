import uvm_pkg::*;
`include "uvm_macros.svh"

class reset_seq extends uvm_sequence #(my_packet);
  `uvm_object_utils(reset_seq)
  function new(string name = "reset_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info("SEQ", "Starting Reset Sequence...", UVM_LOW)
    // Generate a packet with reset asserted
    `uvm_do_with(req, { rst == 1'b1; load == 1'b0; })
  endtask
endclass

class data_10_packets_seq extends uvm_sequence #(my_packet);
  `uvm_object_utils(data_10_packets_seq)
  function new(string name = "data_10_packets_seq");
    super.new(name);
  endfunction
  virtual task body();
    `uvm_info("SEQ", "Starting Data Sequence (10 Packets)...", UVM_LOW)
    for(int i = 0; i < 10; i++) begin
      // Generate packet with random data, reset de-asserted
      `uvm_do_with(req, { rst == 1'b0; load dist { 1'b1 := 2, 1'b0 := 8 };})
    end
  endtask
endclass

class master_sequence extends uvm_sequence #(my_packet);
  `uvm_object_utils(master_sequence)

  reset_seq           r_seq;
  data_10_packets_seq d_seq;

  function new(string name = "master_sequence");
    super.new(name);
  endfunction

  virtual task body();
    r_seq = reset_seq::type_id::create("r_seq");
    d_seq = data_10_packets_seq::type_id::create("d_seq");

    // 1. Run Reset sequence exactly once
    `uvm_info("MASTER_SEQ", "Executing Reset Sequence...", UVM_LOW)
    r_seq.start(m_sequencer); 

    // 2. Run Data sequence to generate your 10 packets with rst de-asserted
    `uvm_info("MASTER_SEQ", "Executing Data Sequence...", UVM_LOW)
    d_seq.start(m_sequencer);
  endtask
endclass
