# ADS1115-I2C-with-AXI-DMA

This project is about send the data from ADS1115 from PL section into PS section through AXI-DMA. Firstly, we create the I2C configuration for ADS1115 and then create AXI configuration that config the register of it. Finally, we pack the data to the master axi streaming interface and send it to memory through AXI-DMA. 

# The example block design for using this core


## src
There are 3 top modules here: i2c_top. axi_for_i2c and data_to_M_AXIS
- i2c_top.vhd is the module that involve i2c_master.vhd and addr_asm.vhd together. The role of this is for create i2c interface and send the data to BRAM and also tick the M_AXIS to initiate communication. 
- axi_for_i2c.vhd is the module that config the pga (programmable gain amplifier) and dr (data rate) of the ADS1115. Moreover it use to send the start command. Note that the start command for this project is the rising edge which means if you want to start you need to turn off before turn on. 
- data_to_M_AXIS is the module that send the address to BRAM for receive the data and send the data in AXI-streaming interface. 

The i2c_master is reference from digikey. 

## sdk 
The C code that use to start the AXI DMA and also communication with the axi_for_i2c.vhd

## bd
block design which is generate from "export block design" in vivado. Note that we did not test this file. 
