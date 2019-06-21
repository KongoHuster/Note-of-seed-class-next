`timescale 1ns / 1ps
//Author: Jianjian Song
//Date:	June 2019
//A complete UART module based on files from Xilinx
module UARTmodule2019spring(rx, tx, read_from_uart, write_to_uart, 
rx_data, tx_data, clock, reset);
output	tx;
input 	rx;
input read_from_uart, write_to_uart;
input  clock, reset;
output [7:0] 	rx_data;
input [7:0] tx_data;

parameter BAUDRATE=20'd19200, FREQUENCY=30'd50000000;
wire  en_16_x_baud;

	BaudRateGenerator BaudRateUnit(en_16_x_baud, reset, clock, BAUDRATE, FREQUENCY);

// Signals for UART connections
//reg read_from_uart, write_to_uart;
wire  	tx_full;
wire  	tx_half_full;
wire  	rx_data_present;
wire  	rx_full;
wire  	rx_half_full;

uart_tx TransmitUnit(	.data_in(tx_data), .write_buffer(write_to_uart),
    	.reset_buffer(1'b0), .en_16_x_baud(en_16_x_baud),
    	.serial_out(tx),.buffer_full(tx_full),
    	.buffer_half_full(),.clk(clock));
		
uart_rx receive
(	.serial_in(rx),
    	.data_out(rx_data),
    	.read_buffer(read_from_uart),
    	.reset_buffer(1'b0),
    	.en_16_x_baud(en_16_x_baud),
    	.buffer_data_present(rx_data_present),
    	.buffer_full(rx_full),
    	.buffer_half_full(rx_half_full),
    	.clk(clock));
endmodule
