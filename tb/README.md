# This folder will contain the sv/uvm testbench for the wider project
## This includes testing:
 1. the waveform generation
 2. the output MUX
 3. DAC output
 4. control software signals

## Run command:
```bash
    verilator --binary --timing -j 0 -Wno-fatal --top-module tb_top +incdir+../lib/uvm/src/ +define+UVM_NO_DPI .. /lib/uvm/src/uvm_pkg.sv fbsg_pkg.sv tb_top.sv
```
