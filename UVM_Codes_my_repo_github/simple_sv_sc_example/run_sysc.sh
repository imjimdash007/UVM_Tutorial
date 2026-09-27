vlib work
sccom -g hello.cc
sccom -link
vsim -voptargs=+acc work.sc_main -c -do "run -all;quit -f"


