#!/bin/bash

TIME=200us
UNIT=adsb_recv_tb
ghdl --clean
ghdl -a ../early_late/early_late.vhd
ghdl -a ../rc_filt/rc_filt.vhd
ghdl -a ../matched_filt/matched_filt.vhd
ghdl -a ../data_slicer/data_slicer.vhd
ghdl -a ../manchester_dec/manchester_dec.vhd
ghdl -a ../preamble_det/preamble_det.vhd
ghdl -a adsb_recv.vhd
ghdl -a $UNIT.vhd
ghdl -e $UNIT
ghdl -m $UNIT 

echo "[ TIME SIMULATION ]";
ghdl -r $UNIT --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
