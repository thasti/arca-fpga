#!/bin/bash

TIME=10us

ghdl --clean
ghdl -a $1.vhd
ghdl -e $1
ghdl -m $1

echo "[ TIME SIMULATION ]";
ghdl -r $1 --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
