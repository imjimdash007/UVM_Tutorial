sccom -work work -stats=none first_counter.cpp first_counter_tb.cpp
sccom -link -work work
vsim -c -novopt work.sc_main