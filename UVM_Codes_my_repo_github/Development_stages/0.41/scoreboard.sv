`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sb extends uvm_scoreboard;
  `uvm_component_utils(my_sb) // Fixed typo

  uvm_tlm_analysis_fifo#(bit [3:0]) exp_fifo;
  uvm_tlm_analysis_fifo#(bit [3:0]) act_fifo;
  
  bit[3:0] expected_data, actual_data; // Fixed typos
  int match_count = 0;
   
  // Constructors can NOT be virtual
  function new(string name, uvm_component parent);
      super.new(name, parent);
      exp_fifo = new("exp_fifo", this);
      act_fifo = new("act_fifo", this);
   endfunction 
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction 
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction 
   
   virtual task run_phase(uvm_phase phase);
      forever begin
         exp_fifo.get(expected_data);
         act_fifo.get(actual_data);	 
         
         if (actual_data !== expected_data) begin
            `uvm_error("MISMATCH", $sformatf("DUT Count: %0d | Expected Count: %0d", actual_data, expected_data)) // Fixed missing parenthesis
         end else begin
            match_count++;	       
            `uvm_info("MATCH", $sformatf("Count Matches! Total Matches = %0d", match_count), UVM_LOW) // Fixed string concatenation syntax
         end
      end
  endtask
endclass

      
   
   
   
         
      
      
   
   
