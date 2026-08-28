`include "uvm_macros.svh"
import uvm_pkg::*;
 
`include "ral_my_design.sv"
 
interface bus_if (input pclk);
   logic [31:0]   paddr;
   logic [31:0]   pwdata;
   logic [31:0]   prdata;
   logic          pwrite;
   logic          psel;
   logic          penable;
   logic          prstn;
endinterface
 
typedef class reg_env;
 
//--------------------------------- bus_pkt {{{1 -----------------------------------
 
class bus_pkt extends uvm_sequence_item;
   rand bit [31:0]  addr;
   rand bit [31:0]  data;
   rand bit         write;
 
   `uvm_object_utils_begin (bus_pkt)
      `uvm_field_int (addr, UVM_ALL_ON)
      `uvm_field_int (data, UVM_ALL_ON)
      `uvm_field_int (write, UVM_ALL_ON)
   `uvm_object_utils_end
 
   function new (string name = "bus_pkt");
      super.new (name);
   endfunction
 
   constraint c_addr { addr inside {0, 4, 8};}
endclass
 
//--------------------------------- my_driver {{{1 -----------------------------------
class my_driver extends uvm_driver #(bus_pkt);
   `uvm_component_utils (my_driver)
 
   bus_pkt  pkt;
 
   virtual bus_if    vif;
 
   function new (string name = "my_driver", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      if (! uvm_config_db#(virtual bus_if)::get (this, "*", "bus_if", vif))
         `uvm_error ("DRVR", "Did not get bus if handle")
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      bit [31:0] data;
 
      vif.psel <= 0;
      vif.penable <= 0;
      vif.pwrite <= 0;
      vif.paddr <= 0;
      vif.pwdata <= 0;
      forever begin
         seq_item_port.get_next_item (pkt);
         if (pkt.write)
            write (pkt.addr, pkt.data);
         else begin
            read (pkt.addr, data);
            pkt.data = data;
         end
         seq_item_port.item_done ();
      end
   endtask
 
   virtual task read (  input bit    [31:0] addr, 
                        output logic [31:0] data);
      vif.paddr <= addr;
      vif.pwrite <= 0;
      vif.psel <= 1;
      @(posedge vif.pclk);
      vif.penable <= 1;
      @(posedge vif.pclk);
      data = vif.prdata;
      vif.psel <= 0;
      vif.penable <= 0;
   endtask
 
   virtual task write ( input bit [31:0] addr,
                        input bit [31:0] data);
      vif.paddr <= addr;
      vif.pwdata <= data;
      vif.pwrite <= 1;
      vif.psel <= 1;
      @(posedge vif.pclk);
      vif.penable <= 1;
      @(posedge vif.pclk);
      vif.psel <= 0;
      vif.penable <= 0;
   endtask
endclass
 
//--------------------------------- my_monitor {{{1 -----------------------------------
class my_monitor extends uvm_monitor;
   `uvm_component_utils (my_monitor)
   function new (string name="my_monitor", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   uvm_analysis_port #(bus_pkt)  mon_ap;
   virtual bus_if                vif;
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      mon_ap = new ("mon_ap", this);
      uvm_config_db #(virtual bus_if)::get (null, "uvm_test_top.*", "bus_if", vif);
   endfunction
 
   virtual task run_phase (uvm_phase phase);
      fork
         forever begin
            @(posedge vif.pclk);
            if (vif.psel & vif.penable & vif.prstn) begin
               bus_pkt pkt = bus_pkt::type_id::create ("pkt");
               pkt.addr = vif.paddr;
               if (vif.pwrite)
                  pkt.data = vif.pwdata;
               else
                  pkt.data = vif.prdata;
               pkt.write = vif.pwrite;
               mon_ap.write (pkt);
            end 
         end
      join_none
   endtask
endclass
 
//--------------------------------- my_agent {{{1 -----------------------------------
class my_agent extends uvm_agent;
   `uvm_component_utils (my_agent)
   function new (string name="my_agent", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   my_driver                  m_drvr;
   my_monitor                 m_mon;
   uvm_sequencer #(bus_pkt)   m_seqr; 
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_drvr = my_driver::type_id::create ("m_drvr", this);
      m_seqr = uvm_sequencer#(bus_pkt)::type_id::create ("m_seqr", this);
      m_mon = my_monitor::type_id::create ("m_mon", this);
   endfunction
 
   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_drvr.seq_item_port.connect (m_seqr.seq_item_export);
   endfunction
endclass
 
//--------------------------------- my_env {{{1 -----------------------------------
class my_env extends uvm_env;
   `uvm_component_utils (my_env)
 
   my_agent       m_agent;   
   reg_env        m_reg_env;
 
   function new (string name = "my_env", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_agent = my_agent::type_id::create ("m_agent", this);
      m_reg_env = reg_env::type_id::create ("m_reg_env", this);
      uvm_reg::include_coverage ("*", UVM_CVR_ALL);
   endfunction
 
   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_reg_env.m_agent = m_agent;
//      m_reg_env.m_reg2apb.tmp_seqr = m_reg_env.m_agent.m_seqr;
      m_agent.m_mon.mon_ap.connect (m_reg_env.m_apb2reg_predictor.bus_in);
      m_reg_env.m_ral_model.default_map.set_sequencer (m_agent.m_seqr, m_reg_env.m_reg2apb);
   endfunction
 
endclass
 
//--------------------------------- my_sequence {{{1 -----------------------------------
class my_sequence extends uvm_sequence;
   `uvm_object_utils (my_sequence)
   function new (string name = "my_sequence");
      super.new (name);
   endfunction
 
   ral_sys_my_design    m_ral_model;  
 
   virtual task body ();
      int rdata;
      uvm_status_e   status;
      uvm_config_db #(ral_sys_my_design)::get (null, "uvm_test_top", "m_ral_model", m_ral_model);
   endtask
endclass
 
//--------------------------------- reset_seq {{{1 -----------------------------------
class reset_seq extends uvm_sequence;
   `uvm_object_utils (reset_seq)
   function new (string name = "reset_seq");
      super.new (name);
   endfunction
 
   virtual bus_if    vif; 
 
   task body ();
      if (!uvm_config_db #(virtual bus_if) :: get (null, "uvm_test_top.*", "bus_if", vif)) 
         `uvm_fatal ("VIF", "No vif")
 
      `uvm_info ("RESET", "Running reset ...", UVM_MEDIUM);
      vif.prstn <= 0;
      @(posedge vif.pclk) vif.prstn <= 1;
      @ (posedge vif.pclk);
   endtask
endclass
 
//--------------------------------- reg2apb_adapter {{{1 -----------------------------------
class reg2apb_adapter extends uvm_reg_adapter;
   `uvm_object_utils (reg2apb_adapter)
//   uvm_sequencer #(bus_pkt)     tmp_seqr;
 
   function new (string name = "reg2apb_adapter");
      super.new (name);
   endfunction
 
   virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
      bus_pkt pkt = bus_pkt::type_id::create ("pkt");
//      pkt.set_sequencer (this.tmp_seqr);
      pkt.write = (rw.kind == UVM_WRITE) ? 1: 0;
      pkt.addr  = rw.addr;
      pkt.data  = rw.data;
      `uvm_info ("adapter", $sformatf ("reg2bus addr=0x%0h data=0x%0h kind=%s", pkt.addr, pkt.data, rw.kind.name), UVM_DEBUG) 
      return pkt; 
   endfunction
 
   virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      bus_pkt pkt;
      if (! $cast (pkt, bus_item)) begin
         `uvm_fatal ("reg2apb_adapter", "Failed to cast bus_item to pkt")
      end
 
      rw.kind = pkt.write ? UVM_WRITE : UVM_READ;
      rw.addr = pkt.addr;
      rw.data = pkt.data;
      `uvm_info ("adapter", $sformatf("bus2reg : addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_DEBUG)
   endfunction
endclass
 
 
//--------------------------------- reg_env {{{1 -----------------------------------
class reg_env extends uvm_env;
   `uvm_component_utils (reg_env)
   function new (string name="reg_env", uvm_component parent);
      super.new (name, parent);
   endfunction
 
   ral_sys_my_design              m_ral_model;         // Register Model
   reg2apb_adapter                m_reg2apb;           // Convert Reg Tx <-> Bus-type packets
   uvm_reg_predictor #(bus_pkt)   m_apb2reg_predictor; // Map APB tx to register in model
   my_agent                       m_agent;             // Agent to drive/monitor transactions
 
   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
      m_ral_model          = ral_sys_my_design::type_id::create ("m_ral_model", this);
      m_reg2apb            = reg2apb_adapter :: type_id :: create ("m_reg2apb");
      m_apb2reg_predictor  = uvm_reg_predictor #(bus_pkt) :: type_id :: create ("m_apb2reg_predictor", this);
 
      m_ral_model.build ();
      m_ral_model.lock_model ();
      uvm_config_db #(ral_sys_my_design)::set (null, "uvm_test_top", "m_ral_model", m_ral_model);
   endfunction
 
   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase (phase);
      m_apb2reg_predictor.map       = m_ral_model.default_map;
      m_apb2reg_predictor.adapter   = m_reg2apb;
   endfunction   
endclass
 
/* // trial test
class my_reg_cbs extends uvm_reg_cbs;
   `uvm_object_utils (my_reg_cbs)
 
   function new (string name="my_reg_cbs");
      super.new (name);
   endfunction
 
   virtual task post_write (uvm_reg_item rw);
      $display ("post write callback name=%s %0d 0x%0h", rw.get_name(), rw.kind, rw.value);
   endtask
endclass 
*/