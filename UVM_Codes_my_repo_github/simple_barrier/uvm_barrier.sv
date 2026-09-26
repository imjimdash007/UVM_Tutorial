//----------------------------------------------------
// www.verificationguide.com
//----------------------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

module uvm_barrier_ex;
  uvm_barrier ba;
 
  initial begin
    ba = new("ba",3);
   
    fork
      begin       //process-1
        $display($time," Inside the process-a");
        #20;
        $display($time," process-a completed");
        $display($time," process-a Waiting for barrier");
        ba.wait_for();
        $display($time," process-a after wait_for");        
      end
     
      begin       //process-2
        $display($time," Inside the process-b");
        #10;
        $display($time," process-b completed");
        $display($time," process-b Waiting for barrier");        
        ba.wait_for();
        $display($time," process-b after wait_for");
      end
     
      begin       //process-3
        $display($time," Inside the process-c");
        #30;
        $display($time," process-c completed");
        $display($time," process-c Waiting for barrier");      
        ba.wait_for();
        $display($time," process-c after wait_for");
      end
     
      begin       //process-4
        $display($time," Inside the process-d");
        #5;
        $display($time," process-d completed");
        $display($time," process-d Waiting for barrier");      
        ba.wait_for();
        $display($time," process-d after wait_for");
      end      
    join
  end
endmodule
