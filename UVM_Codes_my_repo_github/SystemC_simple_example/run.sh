sccom -work work -stats=none hello_World.cpp
sccom -link -work work
vsim -c -novopt work.sc_main