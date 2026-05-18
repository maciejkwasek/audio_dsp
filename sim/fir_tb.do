vlib work
vmap work work

vcom ../../rtl/fir_rom.vhd
vcom ../../rtl/fir_ram.vhd 
vcom ../../rtl/fir.vhd
vcom ../../tb/fir_tb.vhd

vsim work.fir_tb

add wave *

run 50 us
