`timescale 1ns / 1ps

// Module Name:    pong 
//Ported http://www.stevechamberlin.com/cpu/2009/06/21/fpga-pong/ to the Nexys 2 board 
//that we use at Temple U for the Digital Design class. 
//Only had to change the UCF and a little bit of logic. 
//Good starting point for VGA output from a FPGA.

// -----------------------------------------------
// 640x480 @ 60Hz, from a 25MHz input clock
// line duration is slightly longer than spec, but 
// number of lines is fewer to compensate
// -----------------------------------------------
//Revised by Jianjian Song
//from pong 
//10-28-2012
module videoTimerNexys3(input clk25, input Reset,
						 output hsyncOut,
						 output vsyncOut,
						 output [9:0] xposOut,
						 output [9:0] yposOut);

reg [9:0] xpos;
reg [9:0] ypos;

parameter numberOfColumns = 640;	//number of columns
parameter numberOfRows = 480;	//number of lines or rows

always @(posedge clk25 or posedge Reset) begin
	if(Reset==1) xpos<=0;	//added reset, Jianjian Song, 10-28-2012
	else if (xpos>=numberOfColumns-1)
	  xpos <= 0;
	else
	  xpos <= xpos + 1;
end

always @(posedge clk25 or posedge Reset) begin
	if(Reset==1) ypos<=0;
	else if (xpos>=numberOfColumns) begin
		if (ypos >=numberOfRows)
			ypos <= 0;
		else
			ypos <= ypos + 1;	
	end
end
	 
reg hsync, vsync;
always @(posedge clk25 or posedge Reset) 
	if(Reset ==1) begin hsync<=0; vsync<=0; end
	else begin
	hsync <= ~(xpos > 664 && xpos <= 759);  // active for 96 clocks
	vsync <= ~(ypos == 490 || ypos == 491);   // active for lines 490 and 491
end

assign hsyncOut = hsync;
assign vsyncOut = vsync;
assign xposOut = xpos;
assign yposOut = ypos;

endmodule
