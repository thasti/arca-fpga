=========
arca-fpga
=========

FPGA design for the ARCA experiment

this repository includes all FPGA code for the BEXUS ARCA project. it uses an ADC sampling an ADS-B forward-receiver with amplitude detector. the signal is sampled and processed at 16MHz and is output via UART.

The DSP receiver consists of the following integral building blocks:

rc filter - used for smoothing of the input samples for threshold generation

data slicer - used to decide between binary 0 and 1 at the ideal threshold

preamble detector - used to find the preamble pattern in the bit stream

manchester decoder - used to decode manchester bits after a frame start

