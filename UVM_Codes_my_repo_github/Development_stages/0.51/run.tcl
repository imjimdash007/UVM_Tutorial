# Add signals to the wave window
add wave -position insertpoint sim:/counter/clk sim:/counter/rst sim:/counter/load sim:/counter/count_in sim:/counter/count_out

# Force the clock to toggle every 50 ns (100 ns period)
force -freeze sim:/counter/clk 1 0 ns, 0 50 ns -r 100 ns

# Apply initial reset and inputs
force -freeze sim:/counter/rst 1 0
force -freeze sim:/counter/load 0 0
force -freeze sim:/counter/count_in 16#0 0

# Run for the initial reset period (2 clock cycles)
run 200 ns

# Release reset (force it to 0)
force -freeze sim:/counter/rst 0 0

# Run to see it increment a bit (2 clock cycles: count goes 0 -> 1 -> 2)
run 200 ns

# --- NEW: FORCE VALUE 'A' AND LOAD IT HIGH ---
force -freeze sim:/counter/count_in 16#A 0
force -freeze sim:/counter/load 1 0

# Run for 1 clock cycle to let the rising edge capture the load
run 100 ns

# --- NEW: PULL LOAD LOW TO RESUME COUNTING FROM 'A' ---
force -freeze sim:/counter/load 0 0

# Run for a few more cycles to watch it increment (B, C, D...)
run 300 ns


