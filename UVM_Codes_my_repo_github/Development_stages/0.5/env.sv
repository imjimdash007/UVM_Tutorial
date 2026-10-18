`ifndef ENV_SV
`define ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "packet.sv"
`include "agent.sv"
`include "sequence.sv"
`include "ref_model.sv"

class my_env extends uvm_env;
   my_agent        agt_in;
   my_agent        agt_out;
   ref_mod         ref_mod1;
   master_sequence main_seq; 

   `uvm_component_utils(my_env)
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
      ref_mod1 = ref_mod::type_id::create("ref_mod1", this);
      
      // ============================================================
      // 1. CONFIGURE & CREATE INPUT AGENT (Active Mode)
      // ============================================================
      // Set the agent mode
      uvm_config_db#(uvm_active_passive_enum)::set(this, "agt_in", "is_active", UVM_ACTIVE);
      uvm_config_db#(bit)::set(this, "agt_in.mon1", "is_input", 1);
      agt_in = my_agent::type_id::create("agt_in", this);
      
      // ============================================================
      // 2. CONFIGURE & CREATE OUTPUT AGENT (Passive Mode)
      // ============================================================
      // Set the agent mode to PASSIVE so it strips out duplicate drivers/sequencers
      uvm_config_db#(uvm_active_passive_enum)::set(this, "agt_out", "is_active", UVM_PASSIVE);
        uvm_config_db#(bit)::set(this, "agt_out.mon1", "is_input", 0);
        agt_out = my_agent::type_id::create("agt_out", this);

      main_seq = master_sequence::type_id::create("main_seq");
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      // Connect input agent monitor to your reference design model
      agt_in.mon1.ap.connect(ref_mod1.imp_port);
   endfunction 
   
   virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("ENV_RUN", "Starting Master Sequence Flow from Env...", UVM_LOW)
      main_seq.start(agt_in.seq1); 
      #100;
      phase.drop_objection(this);     
   endtask
endclass         

`endif // ENV_SV
