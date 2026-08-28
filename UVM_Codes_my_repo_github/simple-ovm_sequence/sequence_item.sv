////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s             OVM Tutorial             s////
////s           gopi@testbenh.in           s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////

class instruction extends ovm_sequence_item;
  typedef enum {PUSH_A,PUSH_B,ADD,SUB,MUL,DIV,POP_C} inst_t; 
  rand inst_t inst;

  `ovm_object_utils_begin(instruction)
    `ovm_field_enum(inst_t,inst, OVM_ALL_ON)
  `ovm_object_utils_end

  function new (string name = "instruction");
    super.new(name);
  endfunction 

endclass 


