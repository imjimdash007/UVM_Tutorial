`ifndef SCOREBOARD_SV
`define SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "packet.sv"


`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class my_SB extends uvm_scoreboard;
   `uvm_component_utils(my_SB)

   // Separate implementation ports for the two distinct data streams
   uvm_analysis_imp_expected #(my_packet, my_SB) expected;
   uvm_analysis_imp_actual   #(my_packet, my_SB) actual;

   // Storage queue to act as our predictive buffer
   protected my_packet expected_queue[$];

   function new(string name, uvm_component parent);
      super.new(name, parent);
      expected = new("expected", this);
      actual   = new("actual", this);
   endfunction

   // 1. Automatically triggered when the Reference Model writes to the Scoreboard
   virtual function void write_expected(my_packet pack);
      expected_queue.push_back(pack);
      `uvm_info("SB_PREDICT", $sformatf("Stored Prediction: Count Out=%0h (Queue Size: %0d)", pack.count_out, expected_queue.size()), UVM_HIGH)
   endfunction

   // 2. Automatically triggered when the Output Agent Monitor writes to the Scoreboard
   virtual function void write_actual(my_packet pack);
      my_packet exp_pkt;

      if (expected_queue.size() == 0) begin
         `uvm_error("SB_EMPTY_ERROR", $sformatf("Received actual data (%0h) but no prediction exists!", pack.count_out))
         return;
      end

      // Pop the oldest calculated prediction from the queue
      exp_pkt = expected_queue.pop_front();

      // Compare them
      if (exp_pkt.count_out == pack.count_out) begin
         `uvm_info("SB_MATCH", $sformatf("SUCCESS! Expected: %0h Actual: %0h", exp_pkt.count_out, pack.count_out), UVM_LOW)
      end else begin
         `uvm_error("SB_MISMATCH", $sformatf("MISMATCH DETECTED! Expected: %0h Actual: %0h", exp_pkt.count_out, pack.count_out))
      end
   endfunction

endclass

`endif // SCOREBOARD_SV
