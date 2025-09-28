vlib work
vlog CORDIC.v quad_logic.v CORDIC_top.v CORDIC_tb.v
vsim -voptargs=+acc work.CORDIC_tb
add wave *
add wave /CORDIC_tb/DUT_top/sin_sign
add wave /CORDIC_tb/DUT_top/cos_sign
add wave /CORDIC_tb/DUT_top/quad_logic_DUT/angle_norm
add wave /CORDIC_tb/DUT_top/quad_logic_DUT/angle_cordic_out
run -all
#quit -sim