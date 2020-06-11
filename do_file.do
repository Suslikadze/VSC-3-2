_add_menu main controls right SystemButtonFace black RUN_1uS   {run 1000000}
_add_menu main controls right SystemButtonFace blue RUN_10uS   {run 10000000}
_add_menu main controls right SystemButtonFace red  RUN_100uS  {run 100000000}
_add_menu main controls right SystemButtonFace green RUN_1mS   {run 1000000000}
_add_menu main controls right SystemButtonFace magenta  RUN_10mS   {run 10000000000}
_add_menu main controls right SystemButtonFace yellow  RUN_100mS   {run 100000000000}

onerror {resume}
quietly WaveActivateNextPane {} 0

onerror {resume}
quietly WaveActivateNextPane {} 0




add wave -position end  sim:/pixels_vlg_tst/i1/clk_in
add wave -position end sim:/pixels_vlg_tst/i1/clk_100
add wave -position end sim:/pixels_vlg_tst/i1/clk_150
add wave -position sim:/pixels_vlg_tst/i1/Total_sum
add wave -position -decimal end sim:/pixels_vlg_tst/i1/SR_from_mult_0_5
add wave -position -decimal end sim:/pixels_vlg_tst/i1/data_from_multiplicator_0_5
add wave -position -decimal end sim:/pixels_vlg_tst/i1/SR_delta
add wave -position -unsigned sim:/pixels_vlg_tst/i1/SR_for_input
add wave -position -unsigned sim:/pixels_vlg_tst/i1/input_pix