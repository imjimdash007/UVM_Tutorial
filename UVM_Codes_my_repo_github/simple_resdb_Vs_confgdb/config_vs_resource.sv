// An example to demonstrate "last write wins" policy of uvm_config_db compared to uvm_resource_db
	// Use +define+RESOURCE to apply resource_db 
	
	`include "uvm_macros.svh"
	import uvm_pkg::*;
	
	//----------------------------------------------------------------------------------
	//                                    my_env
	//----------------------------------------------------------------------------------
	class my_env extends uvm_env;
	   `uvm_component_utils (my_env)
	   function new (string name = "my_env", uvm_component parent);
	      super.new (name, parent);
	   endfunction
	
	   virtual function void build_phase (uvm_phase phase);
	      int cnt = 1;
	      super.build_phase (phase);
	
	      // Set another value to the same variable name "counter" in database using config and resource db
	      // You'll see in the simulation log that when config_db is used, value set here in the env overwrites
	      // the value set at the test level because of "last write wins" policy
	      // However if the value was set using resource_db throughout, you'll see that this value will NOT overwrite
	      // the value set at the test level, because resource_db gives position in hierarchy higher precedence
	`ifdef RESOURCE       
	      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
	      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s", cnt, phase.get_name()), UVM_MEDIUM)
	`else
	      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
	      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s", cnt, phase.get_name()), UVM_MEDIUM)
	`endif
	   endfunction
	endclass
	
	//----------------------------------------------------------------------------------
	//                                    base_test
	//----------------------------------------------------------------------------------
	class base_test extends uvm_test;
	   `uvm_component_utils (base_test)
	   function new (string name, uvm_component parent = null);
	      super.new (name, parent);
	   endfunction : new
	
	   my_env m_env;
	   
	   virtual function void build_phase (uvm_phase phase);
	      int cnt = 4;
	      super.build_phase (phase);
	
	      m_env = my_env::type_id::create ("m_env", this);
	
	      // Set a variable with some value in the build_phase at the test level using either resource/config db
	`ifdef RESOURCE 
	      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
	      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
	`else
	      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
	      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
	`endif
	   endfunction
	   
	   virtual function void start_of_simulation_phase (uvm_phase phase);
	      int rt,  cnt;
	      
	      // Get the variable set in the build_phase using either config/resource db (let's use config db)
	      uvm_config_db #(int)::get (null, "uvm_test_top", "count", rt);
	      `uvm_info ("PRINT", $sformatf ("Got cnt=%0d using uvm_config_db in %s phase", rt, phase.get_name()), UVM_MEDIUM)
	
	      // Change the value and set it using config/resource db
	      cnt = 123;
	`ifdef RESOURCE
	      uvm_resource_db #(int)::set ("uvm_test_top", "count", cnt);
	      `uvm_info ("RESOURCE", $sformatf ("Set cnt=%0d using uvm_resource_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
	`else
	      uvm_config_db #(int)::set (null, "uvm_test_top", "count", cnt);
	      `uvm_info ("CONFIG", $sformatf ("Set cnt=%0d using uvm_config_db in %s phase", cnt, phase.get_name()), UVM_MEDIUM)
	`endif
	   endfunction
	
	   virtual task main_phase (uvm_phase phase);
	      int rt2;
	      super.main_phase (phase);
	      
	      // Get the value set 
	      uvm_config_db #(int)::get (null, "uvm_test_top", "count", rt2);
	      `uvm_info ("PRINT", $sformatf ("Got cnt=%0d using config_db in %s phase", rt2, phase.get_name()), UVM_MEDIUM)
	   endtask
	endclass 
	
	//----------------------------------------------------------------------------------
	//                                    top
	//----------------------------------------------------------------------------------
	module top;
	   import uvm_pkg::*;
	   
	   initial 
	      run_test ("base_test");
	endmodule
	
