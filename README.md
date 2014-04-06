# arca-fpga

**FPGA design for the ARCA experiment**

this repository includes all FPGA code for the BEXUS ARCA project. it uses an ADC sampling an ADS-B forward-receiver with amplitude detector. the signal is sampled and processed at 16MHz and is output via UART.

## receiver working principle
Input samples are fed into a threshold filter (peak detecting RC filters) and sliced into binary signals. in these signals, the preamble pattern is searched at full sample rate. when a preamble is detected, "start of frame" is issued to the timing recovery and the frame builder is reset. 
Input signals are match-filtered, which converts them from square pulses to triangle pulses, which can then be used for timing syncronisation. for every triangle pulse, early and late samples are taken, which are compared to each other. Depending on the input from the slicer, the timing is corrected forward (late) or backward (early).
From the recovered clock and data from the slicer, the manchester decoder reconstructs the original binary data. Binary symbols are fed into the frame controller, which saves the correct amount of bits (112 or 56, respectively) and issues them into a UART FIFO.

## VHDL entities

### adsb\_gen
the test frame generator can produce arbitrary ADS-B-like frames for analysis and testing of the receiver

### adsb\_recv
this is the receiver design, connecting the various submodules, instantiating all components etc.

### data\_slicer
input data is used to generate a threshold, which is then used to decide between the binary symbols. ADC samples can be input this way and converted to digital bits. it works independently from clock recovery and can act on its own

### early\_late
performs the clock recovery (if it proves neccesary). at the moment, this module only spits out equally spaced clock pulses, but the interface is prepared for implementation of a clock recovery algorithm

### frame\_ctrl
the frame controller does the housekeeping of the receiver, deciding between long and short ADS-B frames and filling the output FIFO for the UART

### led\_timer
a simple module, only used to make short pulses visible for example on LEDs - this one is used to signal a correctly decoded preamble to the user on a LED

### manchester\_dec
another simple one: this one just collects manchester chips and outputs binary symbols. also features an error output for signalling receiving errors (caused for example by interference)

### matched\_filt
a matched filter for improving SNR on the input samples. it is matched to the peaks and is of easy structure. 

### preamble\_det
the preamble detector for detection of frames - this one signals the frame controller that it has to handle a frame.

### rc\_filt
a simple, discrete RC filter equivalent with confiurable time constant - described to use low amounts of hardware

### uart\_fifo
the output module of the receiver. with configurable baud rate, this module transmits the ADS-B frames to a connected computer.

