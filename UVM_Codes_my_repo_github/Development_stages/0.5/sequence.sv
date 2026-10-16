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
  Task
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
      `uvm_do_with(req, { rst == 1'b0; })
    end
  task
endclass

class my_sequence_library extends uvm_sequence_library #(my_packet);
  `uvm_object_utils(my_sequence_library)
  // Define the macro to initialize the library
  `uvm_sequence_library_utils(my_sequence_library)
  function new(string name = "my_sequence_library");
    super.new(name);
    // Add your sequences to this specific library
    add_typewide_sequence(reset_seq::get_type());
    add_typewide_sequence(data_10_packets_seq::get_type());
    // Configure selection mode (e.g., UVM_SEQ_LIB_RAND, UVM_SEQ_LIB_USER, UVM_SEQ_LIB_ITEM)
    init_sequence_library();
  endfunction
endclass
