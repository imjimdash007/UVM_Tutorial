 //Added a new interface for SB/Monitor only
`define hier top_tb.dut    //for the hierarchy

import uvm_pkg::*;
`include "uvm_macros.svh"

interface dummy_if(
  input bit clk,
 // output [7:0] a,
 // output [7:0] b,
 // output       doAdd,
  input [8:0] result
);
endinterface: add_sub_dummy_if

//--------------------------------------------------------------
// environment env
//--------------------------------------------------------------
class env extends uvm_env;
   `uvm_component_utils(env)

  virtual add_sub_dummy_if m_en_if;   //Note the virtual in front of the interface

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
   function void connect_phase(uvm_phase phase);
    `uvm_info("LABEL", "Started connect phase.", UVM_LOW);
    // Get the interface from the resource database.
    assert(uvm_config_db#(virtual add_sub_dummy_if)::get(this,get_full_name(), "add_sub_dummy_if", m_en_if)); //Connected
    `uvm_info("LABEL", "Finished connect phase.", UVM_LOW);
  endfunction: connect_phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("LABEL", "Started run phase.", UVM_LOW);
    begin
    @(m_en_if.clk);
       force top_tb.dut.a0 = 8'h2;  //Whatever you want to force 
       force top_tb.dut.b0 = 8'h3;
       force top_tb.dut.doAdd0 = 'b1;
      repeat(3) @(m_en_if.clk);  //waiting for the clk (Hint: it can be some deep signal if you have assign the same from the design )
      `uvm_info("RESULT     TB", $sformatf("%0d + %0d = %0d", 2, 3, m_en_if.result), UVM_LOW);
    end
    `uvm_info("LABEL", "Finished run phase.", UVM_LOW);
    #400;
    phase.drop_objection(this);
  endtask: run_phase
endclass


module TB_parallel;
  add_sub_dummy_if m_if();
  env      environment;
  assign   m_if.clk =  `hier.clk;
 // assign  `hier.a0 = m_if.a;
 // assign  `hier.b0 = m_if.b;
 // assign  `hier.doAdd0 = m_if.doAdd;
  assign   m_if.result = `hier.result0;
 
  initial begin
    // Put the interface into the resource/config database.
    uvm_config_db#(virtual add_sub_dummy_if)::set(null,"*", "add_sub_dummy_if", m_if);
    environment = new("env2"); // By older method you can give the m_if here also, read http://www.testbench.in/SL_05_PHASE_2_ENVIRONMENT.html
    run_test();
  end
endmodule


initial begin  
      fd = $fopen("my_file.txt", "r");  
  
      // Keep reading lines until EOF is found  
      while (! $feof(fd)) begin  
     status = $fscanf("%c,%h,%h",mode,addr,data); 
     if(status != 3) error;// you did not read in 3 values
       case(mode)
         "r": rw=READ;
         "w": rw=WRITE;
         default: error;
       endcase
    $fgets(str, fd);  
  
        // Display contents of the variable  
        $display("%0s", str);  
$fclose(fd);  

while (fscanf(ifp, "%s %d", username, &score)  ! = EOF) {
   fprintf(ofp, "%s %d\n", username, score+10);

s = "1024";
/* Output: atoi 1024 */
$display("atoi %0d", s.atoi());

str.atoi()	function integer atoi();	Returns the integer corresponding to the ASCII decimal representation in str
str.atohex()	function integer atohex();	Interprets the string as hexadecimal
str.atooct()	function integer atooct();	Interprets the string as octal
str.atobin()	function integer atobin();	Interprets the string as binary
https://www.asic-world.com/scripting/file_io_c.html
string line;
      string first_word_column [];
      fd = $fopen ("myfile.txt", "r");
      while (!$feof(fd)) begin
          code = $fgets (line, fd); //Get entire line
          code = $sscanf (line, "%s", first_word_column[i]); //Get first word of that line
          i++;
      end
      $fclose (fd);
