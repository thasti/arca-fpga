#!/bin/bash

TIME=200us
UNIT=data_slicer_tb
ghdl --clean
ghdl -a data_slicer.vhd
ghdl -a ../rc_filt/rc_filt.vhd
ghdl -a $UNIT.vhd
ghdl -e $UNIT
ghdl -m $UNIT 

echo "[ TIME SIMULATION ]";
ghdl -r $UNIT --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
