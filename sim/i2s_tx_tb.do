vlib work
vmap work work

vcom ../../rtl/i2s_tx.vhd
vcom ../../tb/i2s_tx_tb.vhd

vsim work.i2s_tx_tb

add wave *

run 50 us
