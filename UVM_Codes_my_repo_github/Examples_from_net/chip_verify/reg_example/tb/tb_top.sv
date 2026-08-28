`include "uvm_macros.svh"
import uvm_pkg::*;
 
module tb_top;
   bit pclk;
   always #10 pclk = ~pclk;
 
   bus_if   _if (pclk);
   periphA  pA0 ( .pclk    (_if.pclk),
                  .prstn   (_if.prstn),
                  .paddr   (_if.paddr),
                  .pwdata  (_if.pwdata),
                  .prdata  (_if.prdata),
                  .psel    (_if.psel),
                  .pwrite  (_if.pwrite),
                  .penable (_if.penable));
 
   initial begin 
      uvm_config_db #(virtual bus_if)::set (null, "uvm_test_top.*", "bus_if", _if);
      run_test ("base_test");
   end
endmodule