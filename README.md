=========
arca-fpga
=========

FPGA design for the ARCA experiment

this repository includes all FPGA code for the BEXUS ARCA project. it uses an ADC sampling an ADS-B forward-receiver with amplitude detector. the signal is sampled and processed at 16MHz and is output via UART.

Receiver working principle
========
Input samples are fed into a threshold filter (peak detecting RC filters) and sliced into binary signals. in these signals, the preamble pattern is searched at full sample rate. when a preamble is detected, "start of frame" is issued to the timing recovery and the frame builder is reset. 
Input signals are match-filtered, which converts them from square pulses to triangle pulses, which can then be used for timing syncronisation. for every triangle pulse, early and late samples are taken, which are compared to each other. Depending on the input from the slicer, the timing is corrected forward (late) or backward (early).
From the recovered clock and data from the slicer, the manchester decoder reconstructs the original binary data. Binary symbols are fed into the frame controller, which saves the correct amount of bits (112 or 56, respectively) and issues them into a UART FIFO.

