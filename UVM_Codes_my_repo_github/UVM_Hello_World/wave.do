onerror {resume}
quietly set dataset_list [list sim dump1 dump]
if {[catch {datasetcheck $dataset_list}]} {abort}
quietly WaveActivateNextPane {} 0
add wave -noupdate sim:/top/dut_if1/clock
add wave -noupdate sim:/top/dut_if1/reset
add wave -noupdate sim:/top/dut_if1/cmd
add wave -noupdate sim:/top/dut_if1/addr
add wave -noupdate sim:/top/dut_if1/data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 342
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {89 ns}
