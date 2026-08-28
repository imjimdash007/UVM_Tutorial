
import uvm_pkg::*;
`include "uvm_macros.svh"

interface add_sub_dummy_if(
  input bit clk1,
  input bit clk2,
  input [79:0] a, //from table
  input [79:0] b, //input from the logic
  input [79:0] expected_result //after doing some checks
);
endinterface: add_sub_dummy_if

//------------------------------------------------------------------------------------------
// environment ref_mod
//------------------------------------------------------------------------------------------
class ref_mod extends uvm_monitor;
  `uvm_component_utils(ref_mod)  //factory registration for type_id

  virtual add_sub_dummy_if m_dummy_if;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction

 // typedef uvm_component_registry #(ref_mod, "ref_mod") type_id;
 
  function void connect_phase(uvm_phase phase);
    `uvm_info("LABEL from ref_mod", "Started connect phase.", UVM_HIGH);
    // Get the interface from the config database.
      assert(uvm_config_db#(virtual add_sub_dummy_if)::get(this,get_full_name(), "add_sub_dummy_if", m_dummy_if));
    `uvm_info("LABEL from ref_mod", "Finished connect phase.", UVM_HIGH);
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
   phase.raise_objection(this);
    begin
   `uvm_info("LABEL from ref_mod", "Started run phase.", UVM_HIGH);
      forever begin
       @(posedge m_dummy_if.clk1);
          if(m_dummy_if.expected_result[15:0] == 16'hFF) begin
            `uvm_info("ref_mod","got the correct value", UVM_LOW);
        end
       end
     end
   phase.drop_objection(this);
  endtask: run_phase
endclass

//---------------------------------------------------------------------------------------------
// module testbench3 --> TB to check the ref_model
//---------------------------------------------------------------------------------------------
module testbench3;

  bit clk1,clk2;
  bit[79:0] a,b,expected_result;
  ref_mod env;
  add_sub_dummy_if add_sub_dummy_if(clk1,clk2,a,b,expected_result);

  initial begin
    env = ref_mod::type_id::create("env",null); //"this" cannot be use here since "this" should be  inside class not in module **
    // Put the interface into the config database.
    uvm_config_db#(virtual add_sub_dummy_if)::set(null,"*","add_sub_dummy_if",add_sub_dummy_if);
    clk1 = 0;
    clk2 = 0;
    run_test();
  end

  initial begin
    forever begin
      #(50) clk1 = ~clk1;
    end
  end

  initial begin
    forever begin
      #(50) clk2 = ~clk2;
    end
  end
 
   initial begin
     #0 expected_result = 'h00;
     #500 expected_result = 'hFF;
     #150 expected_result = 'h00;
     #1000 $finish;
   end
endmodule
