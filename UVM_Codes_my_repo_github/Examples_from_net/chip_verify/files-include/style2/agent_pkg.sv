// Create a package and `include all files in here
// Then we can import this package in the top module
// or wherever necessary
 
package agent_pkg;
   `include "apb_agent.sv"
   `include "wb_agent.sv"
   `include "spi_agent.sv"
endpackage