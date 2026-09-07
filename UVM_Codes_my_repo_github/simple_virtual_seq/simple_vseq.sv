import uvm_pkg::*;
`include "uvm_macros.svh"

// ============================================================================
// 1. SUB-SEQUENCERS (No actual sequence items needed for this demo)
// ============================================================================
class cpu_sequencer extends uvm_sequencer;
  `uvm_component_utils(cpu_sequencer)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
endclass

class mem_sequencer extends uvm_sequencer;
  `uvm_component_utils(mem_sequencer)
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
endclass

// ============================================================================
// 2. VIRTUAL SEQUENCER (Holds handles to sub-sequencers)
// ============================================================================
class my_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(my_virtual_sequencer)
  
  cpu_sequencer cpu_sqr;
  mem_sequencer mem_sqr;
  
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
endclass

// ============================================================================
// 3. VIRTUAL SEQUENCE (Demonstrates m_sequencer vs p_sequencer)
// ============================================================================
class my_virtual_seq extends uvm_sequence;
  `uvm_object_utils(my_virtual_seq)
  
  // MAGIC MACRO: Automatically creates 'p_sequencer' and casts 'm_sequencer' into it.
  `uvm_declare_p_sequencer(my_virtual_sequencer)

  function new(string name="my_virtual_seq"); super.new(name); endfunction

  task body();
    my_virtual_sequencer manual_cast_sqr;

    `uvm_info("SEQ", "Starting Virtual Sequence...", UVM_NONE)

    repeat(3) begin
      #10; // Add delay as requested
      
      // --- APPROACH 1: Using m_sequencer (Requires manual casting) ---
      if (!$cast(manual_cast_sqr, m_sequencer)) begin
        `uvm_fatal("SEQ", "Failed to cast m_sequencer to my_virtual_sequencer")
      end
      `uvm_info("M_SQR", $sformatf("[Time: %0t] Using m_sequencer cast: CPU SQR path = %s", 
                $time, manual_cast_sqr.cpu_sqr.get_full_name()), UVM_NONE)

      // --- APPROACH 2: Using p_sequencer (Direct access) ---
      `uvm_info("P_SQR", $sformatf("[Time: %0t] Using p_sequencer: MEM SQR path = %s", 
                $time, p_sequencer.mem_sqr.get_full_name()), UVM_NONE)
                
      `uvm_info("SEQ", "--------------------------------------------------", UVM_NONE)
    end
  endtask
endclass

// ============================================================================
// 4. ENVIRONMENT (Instantiates and connects sequencers)
// ============================================================================
class env extends uvm_env;
  `uvm_component_utils(env)
  
  cpu_sequencer        cpu_sqr;
  mem_sequencer        mem_sqr;
  my_virtual_sequencer v_sqr;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  
  function void build_phase(uvm_phase phase);
    cpu_sqr = cpu_sequencer::type_id::create("cpu_sqr", this);
    mem_sqr = mem_sequencer::type_id::create("mem_sqr", this);
    v_sqr   = my_virtual_sequencer::type_id::create("v_sqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    // Assign local physical sequencers to the virtual sequencer's handles
    v_sqr.cpu_sqr = this.cpu_sqr;
    v_sqr.mem_sqr = this.mem_sqr;
  endfunction
endclass

// ============================================================================
// 5. TEST (Starts the virtual sequence)
// ============================================================================
class vseq_test extends uvm_test;
  `uvm_component_utils(vseq_test)
  
  env e;

  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  
  function void build_phase(uvm_phase phase);
    e = env::type_id::create("e", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    my_virtual_seq vseq = my_virtual_seq::type_id::create("vseq");
    
    phase.raise_objection(this);
    // Start the virtual sequence on the virtual sequencer
    vseq.start(e.v_sqr); 
    phase.drop_objection(this);
  endtask
endclass

// ============================================================================
// 6. TOP MODULE
// ============================================================================
module tb_top;
  initial begin
    run_test("vseq_test");
  end
endmodule // tb_top
/*
 vlib work
 vlog simple_vseq.sv
 vsim -gui -classdebug -uvmcontrol=all tb_top -do "run 0"
*/
