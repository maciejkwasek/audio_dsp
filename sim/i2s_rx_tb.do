vlib work
vmap work work

vcom ../../rtl/i2s_rx.vhd
vcom ../../tb/i2s_rx_tb.vhd

vsim work.i2s_rx_tb

add wave *

run 100 us
