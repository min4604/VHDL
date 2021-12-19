onerror {quit -f}
vlib work
vlog -work work and_not_or.vo
vlog -work work and_not_or.vt
vsim -novopt -c -t 1ps -L max3000a_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.and_not_or_vlg_vec_tst
vcd file -direction and_not_or.msim.vcd
vcd add -internal and_not_or_vlg_vec_tst/*
vcd add -internal and_not_or_vlg_vec_tst/i1/*
add wave /*
run -all
