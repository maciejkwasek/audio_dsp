vlib work
vmap work work

vcom ../../rtl/dds_sin.vhd
vcom ../../tb/dds_sin_tb.vhd

vsim work.dds_sin_tb

add wave *

run 5 us
