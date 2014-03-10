#!/bin/bash

TIME=200us
UNIT=preamble_det_tb
ghdl --clean
ghdl -a $UNIT.vhd
ghdl -e $UNIT
ghdl -m $UNIT

echo "[ TIME SIMULATION ]";
ghdl -r $UNIT --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
