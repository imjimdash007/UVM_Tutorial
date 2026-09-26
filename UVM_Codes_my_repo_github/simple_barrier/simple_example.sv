`include "uvm_macros.svh"
import uvm_pkg::*;

module barrier_example();
  uvm_barrier br;

  task automatic run_process(string name, int p_delay);
    $display("@%0t: Process %s started", $time, name);
    #p_delay;
    $display("@%0t: Process %s reached the barrier", $time, name);
    
    // Block until threshold number of processes reach here
    br.wait_for(); 
    
    $display("@%0t: Process %s unblocked", $time, name);
  endtask

  initial begin
    // Construct the barrier object with a name
    br = new("br");
    
    // Set threshold to 4 processes
    br.set_threshold(4); 

    // Fork 4 concurrent processes that will trigger the barrier
    fork
      run_process("A", 5);
      run_process("B", 10);
      run_process("C", 15);
      run_process("D", 20);
    join
    
    $display("@%0t: Simulation finished", $time);
  end
endmodule

