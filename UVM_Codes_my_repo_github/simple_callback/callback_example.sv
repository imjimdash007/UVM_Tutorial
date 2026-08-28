`include "uvm_macros.svh"
import uvm_pkg::*;

class Driver_callback extends uvm_callback;
  function new (string name = "Driver_callback");
    super.new(name);
  endfunction
  static string type_name = "Driver_callback";
  virtual function string get_type_name();
    return type_name;
  endfunction
  virtual task pre_send(); endtask
  virtual task post_send(); endtask
endclass : Driver_callback

class Driver extends uvm_component;
  `uvm_component_utils(Driver)
  `uvm_register_cb(Driver,Driver_callback)
  function new (string name, uvm_component parent=null);
    super.new(name,parent);
  endfunction
 virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    repeat(2) begin 
         `uvm_do_callbacks(Driver,Driver_callback,pre_send())
         $display(" Driver: Started Driving the packet ...... %d",$time);  
         // Logic to drive the packet goes hear
         // let's consider that it takes 40 time units to drive a packet.
         #40; 
         $display(" Driver: Finished Driving the packet ...... %d",$time);   
         `uvm_do_callbacks(Driver,Driver_callback,post_send())
         #40;
     end
   phase.drop_objection(this);
  endtask
endclass

class Custom_Driver_callbacks_1 extends Driver_callback;
     function new (string name = "Driver_callback");
        super.new(name);
     endfunction
     virtual task pre_send();
       $display("CB_1:pre_send: Delaying the packet driving by 20 time units. %d",$time);
       #20;
     endtask
     virtual task post_send();
      $display("CB_1:post_send: Just a message from  post send callback method \n");
     endtask
 endclass 

module test;
 initial begin
  Driver drvr;
  Custom_Driver_callbacks_1 cb_1;
  drvr = new("drvr");
  cb_1 = new("cb_1");
  uvm_callbacks #(Driver,Driver_callback)::add(drvr,cb_1);
  uvm_callbacks #(Driver,Driver_callback)::display();
  run_test();
end 
endmodule 
