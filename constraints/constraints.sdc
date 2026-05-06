# 50 MHz → okres = 20 ns
create_clock -period 20 -name clk_50MHz [get_ports clk]

create_generated_clock -name clk_96 \
    -source [get_ports clk] \
    [get_pins pll96|c0] \
    -divide_by 1

create_generated_clock -name clk_24_576 \
    -source [get_pins pll96|c0] \
    [get_pins pll24_576|c0] \
    -multiply_by 1
