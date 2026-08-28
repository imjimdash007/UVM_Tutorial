import uvm_pkg::*;
`include "uvm_macros.svh"

class env extends uvm_env;
`uvm_component_utils(env)
    int a;
    string color;

   function new(string name, uvm_component parent);
    super.new(name, parent);
   endfunction

  virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
    if(!uvm_config_db #(uvm_bitstream_t):: get(this, "", "a", a))
      `uvm_fatal("GET_NOTSUCC", "Get is not successful for a..");
     if(!uvm_config_db #(string):: get(this, "", "color", color))
      `uvm_fatal("GET_NOTSUCC", "Get is not successful for color..");
     `uvm_info("GET_VALUE",  $psprintf ("The value of a1 = %d color = %s",a,color),UVM_LOW);
      $display("The value of color = %s",color);
  endfunction
 endclass
 
class test extends uvm_test;
   `uvm_component_utils(test)
    int a;
    string color;
    env env_i;
   
    function new (string name = "test", uvm_component parent = null);
       super.new(name,parent);
   endfunction 

   virtual function void build_phase(uvm_phase phase);
    super.build_phase (phase);
    env_i = env::type_id::create("env_i",  this);
    uvm_config_db#(uvm_bitstream_t)::set(this, "env_i", "a", a);
    uvm_config_db#(string)::set(this, "env_i", "color", color);
   endfunction 
 endclass 

module top();
  initial begin
    run_test("test");
  end
endmodule : top
// vlog -work work -vopt -sv -stats=none +incdir+C:/questasim_10.6c/uvm-1.1d/../verilog_src/uvm-1.1d/src 
//+incdir+C:/questasim_10.6c/uvm-1.1d/win32/uvm_dpi.dll setting_command_line.sv
// vsim -novopt work.top +uvm_set_config_int=uvm_test_top.env_i,a,6 +uvm_set_config_string=uvm_test_top.env_i,color,red 
//+UVM_CONFIG_DB_TRACE -c "+define+UVM_NO_RELNOTES" -sv_lib C:/questasim_10.6c/uvm-1.1d/win32/uvm_dpi