//-----------------------------------------------------------------------------
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Top Level module to hold Test and Environment Objects  
//-----------------------------------------------------------------------------
 
`timescale 1ns/1ps
import uvm_pkg::*;
import my_pkg::*;
 
module tb_top;
   initial 
      run_test ("base_test");
endmodule