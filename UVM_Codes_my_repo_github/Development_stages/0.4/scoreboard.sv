`include "uvm_macros.svh"
import uvm_pkg::*;

class my_sb extends uvm_scoreboard;
 `uvm_componet_utils(my_sb)
  uvm_analysis_export#(bit [3:0]) exp;
  uvm_analysis_export#(bit [3:0]) act;
  uvm_tlm_analysis_fifo#(bit [3:0]) exp_fifo;
  uvm_tlm_analysis_fifo#(bit [3:0]) act_fifo;
  bit[3:0] exected_data,actual_data;
  int	   match_count = 0;
   
  virtual function new(string name,uvm_component parent);
      super.new(name,parent);
   endfunction 
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      exp = uvm_analysis_export::type_id_create("exp")
      act = uvm_analysis_export::type_id_create("act")
      exp_fifo = uvm_tlm_analysis_fifo::type_id_create("exp_fifo")
      act_fifo = uvm_tlm_analysis_fifo::type_id_create("act_fifo")
   endfunction // build_phase
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      exp_export.connect(exp_fifo.analysis_export)
      act_export.connect(act_fifo.analysis_export) 	
   endfunction // connect_phase
   virtual task run_phase(uvm_phase phase);
      forever  begin
	 exp_fifo.get(expected_data);
	 act_fifo.get(actual_data);	 
	 if (actual_data !== expected_data) begin
            `uvm_error("MISMATCH", $sformatf("DUT: %0d | EXP: %0d",actual_data , expected_data)
	 end else begin
	     match_count++;	       
            `uvm_info("MATCH", $sformatf("Count Matches:%d".match_count), UVM_LOW)
	 end
      end
  endtask
endclass	
      
   
   
   
         
      
      
   
   
