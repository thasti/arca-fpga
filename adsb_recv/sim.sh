#!/bin/bash

TIME=30ms
UNIT=adsb_recv_tb
ghdl --clean
ghdl -a ../adsb_gen/adsb_gen.vhd
ghdl -a ../led_timer/led_timer.vhd
ghdl -a ../early_late/early_late.vhd
ghdl -a ../rc_filt/rc_filt.vhd
ghdl -a ../matched_filt/matched_filt.vhd
ghdl -a ../data_slicer/data_slicer.vhd
ghdl -a ../manchester_dec/manchester_dec.vhd
ghdl -a ../preamble_det/preamble_det.vhd
ghdl -a ../uart_fifo/asm.vhd
ghdl -a ../uart_fifo/baudrategenerator.vhd
ghdl -a ../uart_fifo/counter.vhd
ghdl -a ../uart_fifo/fifo.vhd
ghdl -a ../uart_fifo/shiftregister.vhd
ghdl -a ../uart_fifo/uart.vhd
ghdl -a ../frame_ctrl/frame_ctrl.vhd
ghdl -a adsb_recv.vhd
ghdl -a $UNIT.vhd
ghdl -e $UNIT
ghdl -m $UNIT 

echo "[ TIME SIMULATION ]";
ghdl -r $UNIT --wave=output.ghw  --stop-time=$TIME
gtkwave output.ghw gtkwave.sav
ghdl --clean
