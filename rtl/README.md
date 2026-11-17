# This folder contains the rtl for the project
## top
The top-level module that will take in the various subsystems to work the whole generator

## wave_gen
The different wave types the generator can create are stored within here:
- pulse
- square
- sawtooth
- sine
This also contains the shared phase accumulator used by all wave types

## control
The internal FSM and MUXing systems
- drivers for each DAC
- sample timer to divide master clock
- MUX wave outputs so only one is used at a time
- FSM for FBSG state and ctrl_in word partitioning

# dev TBs
Each wave generator has a "dev tb". These are simple verilog-only testbenches to check values are being outputted and that they look correct.
It does not check any deeper processing, input, or output as that is left for the actual uvm testbench.
To run these:
```bash
    iverilog -g2012 -o sim.vvp dev_tb.v wave_gen.v
    vvp sim.vvp
    gtkwave waves.vcd
```