//-----------------------------------------------------------------------------
// Author      :  Admin
// Email       :  contact@chipverify.com
// Description :  Test package
//-----------------------------------------------------------------------------
 
`include "uvm_macros.svh"
 
package test_pkg;
   import uvm_pkg::*;
   import my_pkg::*;
 
class base_test extends uvm_test;
   `uvm_component_utils (base_test)
 
   my_data obj0;
   derivative dv0;
   uvm_table_printer tprinter;
 
   function new (string name = "base_test", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      obj0 = my_data::type_id::create ("obj0");
      dv0 = derivative::type_id::create ("dv0");
      tprinter = new();
      cfg_printer();
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      void'(obj0.randomize());
      `uvm_info ("TST", "print() called with no arguments", UVM_MEDIUM)
      obj0.print ();     // uses uvm_default_printer
 
      `uvm_info ("TST", "Calling print (uvm_default_line_printer)", UVM_MEDIUM)
      obj0.print (uvm_default_line_printer);
 
      `uvm_info ("TST", "Calling print (uvm_default_tree_printer)", UVM_MEDIUM)
      obj0.print (uvm_default_tree_printer);
 
      `uvm_info ("TST", "Calling print (uvm_default_table_printer)", UVM_MEDIUM)
      obj0.print (uvm_default_table_printer);
 
      `uvm_info ("TST", "Calling print (tprinter)", UVM_MEDIUM)
      obj0.print (tprinter);
 
      `uvm_info ("TST", "Print derivative (tprinter)", UVM_MEDIUM)
      dv0.print (uvm_default_table_printer);
   endtask
 
   virtual function void cfg_printer ();
      tprinter.knobs.full_name = 1;
      tprinter.knobs.size = 0;
      tprinter.knobs.depth = 1;
      tprinter.knobs.reference = 2;
      tprinter.knobs.type_name = 0;
      tprinter.knobs.indent = 4;
      tprinter.knobs.hex_radix = "0x";
   endfunction
 
endclass
 
 
endpackage