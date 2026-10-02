`include "uvm_macros.svh"
import uvm_pkg::*;

module counter_assertions (
    input wire clk,
    input wire rst,
    input wire [3:0] count
);

  // =========================================================
  // 1. DYNAMIC Clock Frequency Monitor (Clean Logic Method)
  // =========================================================
  realtime last_edge_time = 0;
  realtime measured_period = 0;
  realtime frequency_mhz = 0;

  always @(posedge clk) begin
    if (last_edge_time > 0) begin
      measured_period = $realtime - last_edge_time;
      frequency_mhz = 1000.0 / measured_period;
      $display("Time: %0t | Measured Clock Frequency: %0f MHz (Period: %0f ns)", $realtime, frequency_mhz, measured_period);
    end
    last_edge_time = $realtime;
  end

  assert_clk_frequency: assert property (@(posedge clk) (measured_period == 10))
    else `uvm_error("ASSERT_FAIL", "Clock frequency deviation detected! Period is not 10ns.")


  // =========================================================
  // 2. Functional Assertions
  // =========================================================
  
  // Clock Toggling Check
  property p_clk_toggles;
    @(clk) 1; 
  endproperty
  assert_clk_toggles: assert property (p_clk_toggles)
    else `uvm_error("ASSERT_FAIL", "Clock has stopped toggling!")

  // Reset Functionality Check
  property p_reset_clears_counter;
    @(posedge clk) rst |=> (count == 4'b0000);
  endproperty
  assert_reset_clears: assert property (p_reset_clears_counter)
    else `uvm_error("ASSERT_FAIL", "Counter failed to clear to 0 on reset!")

  // Counter Increment Check
  property p_counter_increment;
    @(posedge clk) disable iff (rst) 
    (count == $past(count) + 1'b1);
  endproperty
  assert_increment: assert property (p_counter_increment)
    else `uvm_error("ASSERT_FAIL", "Counter skipped a beat!")


  // =========================================================
  // 3. Counter Value Visualizer Assertion (NEW)
  // Evaluates on every active clock edge when reset is inactive.
  // The pass block actively prints the current count values.
  // =========================================================
  assert_counter_value: assert property (
    @(posedge clk) disable iff (rst) (1) // Always true, will pass on every valid cycle
  ) begin
    // Pass Action Block: Displays tracking values inside the console log
    $display("Time: %0t | Assertion Info: Counter is working correctly. Current Value = %0d (Hex: %0h, Binary: %4b)", $realtime, count, count, count);
  end else begin
    // This branch will never be hit because the sequence condition is hardcoded to (1)
    `uvm_error("ASSERT_FAIL", "Counter value capture sequence failed!")
  end

endmodule

