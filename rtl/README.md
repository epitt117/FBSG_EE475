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