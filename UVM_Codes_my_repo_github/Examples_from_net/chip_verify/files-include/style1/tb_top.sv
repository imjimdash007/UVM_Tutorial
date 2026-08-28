//-----------------------------------------------------------------------------
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------
 
`timescale 1ns/1ps
 
 
// Include all the files in here - remember that order matters
// else you get cross-reference compiler errors
`include "apb_agent.sv"
`include "wb_agent.sv"
`include "spi_agent.sv"
`include "my_pkg.sv"
 
import uvm_pkg::*;
 
module tb_top;
   initial begin
      run_test ("base_test");
   end
 
endmodule