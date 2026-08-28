////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s             OVM Tutorial             s////
////s           gopi@testbenh.in           s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////

class seq_a extends ovm_sequence #(instruction);

  instruction req;
 
  function new(string name="seq_a");
    super.new(name);
  endfunction
  
  `ovm_sequence_utils(seq_a, instruction_sequencer)    

  virtual task body();
      repeat(4) begin
         `ovm_do_with(req, { inst == PUSH_A; });
      end
  endtask
  
endclass 

class seq_b extends ovm_sequence #(instruction);

  instruction req;
 
  function new(string name="seq_b");
    super.new(name);
  endfunction
  
  `ovm_sequence_utils(seq_b, instruction_sequencer)    

  virtual task body();
      #25;
      grab();
      repeat(4) begin
         `ovm_do_with(req, { inst == PUSH_B; });
      end
      ungrab();
  endtask
  
endclass 

class seq_c extends ovm_sequence #(instruction);

  instruction req;
 
  function new(string name="seq_c");
    super.new(name);
  endfunction
  
  `ovm_sequence_utils(seq_c, instruction_sequencer)    

  virtual task body();
      repeat(4) begin
         `ovm_do_with(req, { inst == POP_C; });
      end
  endtask
  
endclass 

class parallel_sequence extends ovm_sequence #(instruction);

  seq_a s_a;
  seq_b s_b;
  seq_c s_c;
 
  function new(string name="parallel_sequence");
    super.new(name);
  endfunction
  
  `ovm_sequence_utils(parallel_sequence, instruction_sequencer)    

  virtual task body();
      fork
         `ovm_do(s_a)
         `ovm_do(s_b)
         `ovm_do(s_c)
      join
  endtask
  
endclass 

