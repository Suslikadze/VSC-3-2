transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Suslikadze/Desktop/NII\ Televidenia/VSC {C:/Users/Suslikadze/Desktop/NII Televidenia/VSC/Parameters.v}
vlog -vlog01compat -work work +incdir+C:/Users/Suslikadze/Desktop/NII\ Televidenia/VSC {C:/Users/Suslikadze/Desktop/NII Televidenia/VSC/RAM_1.v}
vlog -vlog01compat -work work +incdir+C:/Users/Suslikadze/Desktop/NII\ Televidenia/VSC {C:/Users/Suslikadze/Desktop/NII Televidenia/VSC/Lines.v}

vlog -vlog01compat -work work +incdir+C:/Users/Suslikadze/Desktop/NII\ Televidenia/VSC/simulation/modelsim {C:/Users/Suslikadze/Desktop/NII Televidenia/VSC/simulation/modelsim/compression.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  compression_video_vlg_tst2

add wave *
view structure
view signals
run -all
