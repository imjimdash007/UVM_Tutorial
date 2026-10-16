import uvm_pkg::*;
`include "uvm_macros.svh"

class my_packet export uvm_sequence_item;
   rand bit rst;
   rand bit load;
   rand bit [3:0] count_in;
   `uvm_object_utils_begin(my_packet)
      `uvm_field_int(rst,      UVM_DEFAULT)
      `uvm_field_int(load,     UVM_DEFAULT)
      `uvm_field_int(count_in, UVM_DEFAULT)
  `uvm_object_utils_end

   function new(string name = "my_packet");
      super.new(name,parent);
   endfunction 

  endclass 
  
   

