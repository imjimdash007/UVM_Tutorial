`include "uvm_macros.svh"
`include "uvm_pkg.sv"
import uvm_pkg::*;

class base_env extends uvm_env;
 `uvm_component_utils (base_env)
string name;
 function new (string name = "base_env", uvm_component parent = null);
   super.new(name, parent);
 endfunction
 virtual function void build_phase (uvm_phase phase);
   super.build_phase(phase);
    // Retrieve the string that was set in config_db from the test class
    if (!uvm_config_db #(string) :: get (null, "uvm_test_top", "Friend", name))
      `uvm_info ("ENV", $sformatf ("not Found my name %s", name), UVM_LOW)
     else
      `uvm_info ("ENV", $sformatf ("Found my name %s", name), UVM_LOW)
endfunction
task main_phase(uvm_phase phase);
 phase.raise_objection(this); 
  if(name == "Ajay")
     `uvm_info("TEST","Test passed with name Ajay", UVM_LOW)
   else 
     `uvm_info("TEST","Test failed with name Ajay", UVM_LOW)
  phase.drop_objection(this);
 endtask
endclass

class base_test extends uvm_test;
  `uvm_component_utils (base_test)
 base_env   m_env;
function new (string name = "base_test", uvm_component parent = null);
   super.new(name, parent);
 endfunction
 virtual function void build_phase (uvm_phase phase);
 super.build_phase(phase);
    // Set this string into config_db
   uvm_config_db #(string) :: set (null, "uvm_test_top", "Friend", "Ajay");
 endfunction
 task main_phase(uvm_phase phase);
  phase.raise_objection(this); 
     `uvm_info("TEST","Test passed", UVM_LOW);
    #100;
 phase.drop_objection(this);
 endtask
endclass

module top();
  initial begin
    run_test("base_test");
    #10;
  end
endmodule