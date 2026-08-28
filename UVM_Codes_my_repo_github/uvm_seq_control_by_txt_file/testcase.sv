 
 `timescale 1ns/1ns

 import uvm_pkg::*;
`include "uvm_macros.svh"

`include "sequence_item.sv"
`include "sequencer.sv"
`include "sequence.sv"
`include "driver.sv"

module test;


  instruction_sequencer sequencer;
  instruction_driver driver;

  initial begin
    set_config_string("sequencer", "default_sequence", "operation_addition");
    sequencer = new("sequencer", null); 
    sequencer.build();
    driver = new("driver", null); 
    driver.build();

    driver.seq_item_port.connect(sequencer.seq_item_export);
    sequencer.print();

    uvm_top.set_timeout(100, 1);  

    fork 
      begin
        run_test();
        sequencer.start_default_sequence();
      end
      #2000 global_stop_request();
    join
  end

endmodule

