//-----------------------------------------------------------------------------
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------
 
`timescale 1ns/1ps
 
import uvm_pkg::*;
`include "my_pkg.sv"

module tb_top;
   initial begin
      run_test ("base_test");
   end
 
endmodule