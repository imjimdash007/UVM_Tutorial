//-----------------------------------------------------------------------------
// Author         :  Admin 
// E-Mail         :  contact@chipverify.com
// Description    :  Package of verification components
//-----------------------------------------------------------------------------
 
`include "uvm_macros.svh"
 
package my_pkg;
   // If you don't use this, it'll complain that it doesn't recognize uvm components
   import uvm_pkg::*;
 
   typedef class colors;
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 format
   //---------------------------------------------------------------------------------------------------------------------
   class format extends uvm_sequence_item;
 
      rand bit [3:0]    header;
      rand bit [2:0]    footer;
      rand bit          enable;
      rand bit [1:0]    body;
      rand colors     m_color;
 
      `uvm_object_utils_begin (format)
         `uvm_field_int (header, UVM_ALL_ON)
         `uvm_field_int (footer, UVM_ALL_ON)
         `uvm_field_int (enable, UVM_ALL_ON)
         `uvm_field_int (body, UVM_ALL_ON)
      `uvm_object_utils_end
 
      function new (string name = "format");
         super.new (name);
         m_color = colors::type_id::create ("m_color");
      endfunction
 
      virtual function void do_print (uvm_printer printer);
         printer.print_object ("m_color", m_color);
      endfunction
   endclass
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 my_data  
   //---------------------------------------------------------------------------------------------------------------------
   class my_data extends uvm_sequence_item;
      rand format           m_format0;
      rand bit [7:0]   data;
      rand bit [7:0]   addr;
 
      constraint c_addr { addr > 0; addr < 8;}
 
      `uvm_object_utils_begin (my_data)
         `uvm_field_int (data, UVM_ALL_ON)
         `uvm_field_int (addr, UVM_ALL_ON)
         `uvm_field_object (m_format0, UVM_ALL_ON)
      `uvm_object_utils_end
 
      function new (string name = "my_data");
         super.new (name);
         m_format0 = format::type_id::create ("m_format0");
      endfunction
   endclass  
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 colors
   //---------------------------------------------------------------------------------------------------------------------
   class colors extends uvm_sequence_item;
      rand bit [3:0] color;
      rand bit       enable;
 
      `uvm_object_utils_begin (colors)
         `uvm_field_int (color, UVM_ALL_ON)
         `uvm_field_int (enable, UVM_ALL_ON)
      `uvm_object_utils_end
 
   endclass
 
   //---------------------------------------------------------------------------------------------------------------------
   //                                                 derivative
   //---------------------------------------------------------------------------------------------------------------------
   class derivative extends my_data;
      `uvm_object_utils (derivative)
 
      rand bit [2:0] mode;
 
      function new (string name="derivative");
         super.new (name);
      endfunction
 
      virtual function void do_print (uvm_printer printer);
         printer.knobs.depth=0;
         printer.print_int ("mode", mode, $bits(mode));
         `uvm_info ("DVR", "do_print called", UVM_MEDIUM)
      endfunction
   endclass 
 
endpackage