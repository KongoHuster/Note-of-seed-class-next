`timescale 1ns / 1ps

// Create Date:    07:41:47 06/21/2009 
// Design Name: 
// Module Name:    pong 
//Ported http://www.stevechamberlin.com/cpu/2009/06/21/fpga-pong/ to the Nexys 2 board 
//that we use at Temple U for the Digital Design class. 
//Only had to change the UCF and a little bit of logic. 
//Good starting point for VGA output from a FPGA.
//
// -----------------------------------------------
// 640x480 @ 60Hz, from a 25MHz input clock
// line duration is slightly longer than spec, but 
// number of lines is fewer to compensate
// -----------------------------------------------
module video_timer(input clk25, input Reset,
						 output hsyncOut,
						 output vsyncOut,
						 output [9:0] xposOut,
						 output [9:0] yposOut);

reg [9:0] xpos;
reg [9:0] ypos;

wire endline = (xpos == 799);

always @(posedge clk25 or posedge Reset) 
	if (Reset==1) xpos<=0;
	else begin
	if (endline)
	  xpos <= 0;
	else
	  xpos <= xpos + 1'b1;
end

always @(posedge clk25 or posedge Reset) 
	if(Reset==1) ypos<=0;
	else begin
	if (endline) begin
		if (ypos == 520)
			ypos <= 0;
		else
			ypos <= ypos + 1'b1;	
	end
end
	 
reg hsync, vsync;
always @(posedge clk25 or posedge Reset) 
	if(Reset==1) begin hsync<=0; vsync<=0; end
	else
	begin
	hsync <= ~(xpos > 664 && xpos <= 759);  // active for 96 clocks
	vsync <= ~(ypos == 490 || ypos == 491);   // active for lines 490 and 491
end

assign hsyncOut = hsync;
assign vsyncOut = vsync;
assign xposOut = xpos;
assign yposOut = ypos;

endmodule

// -----------------------------------------------
// top-level module
// -----------------------------------------------
//modified to work on Zybo board
//Jianjian song, June 2019
module pongZybo2019spring(
    input Clock,
	 input Reset,
    input rota,
    input rotb,
    output [4:0] red,
    output [5:0] green,
    output [4:0] blue,
    output hsync,
    output vsync
    );

wire clk25_int, clk25;
parameter OutClockFrequency=10'd25, InputClockFrequency=10'd125;    //MHz
//module ClockGenerator (OutClockFrequency, InputClockFrequency, OutClock, Reset, clock);
ClockGenerator ClockUnit(OutClockFrequency, InputClockFrequency, clk25_int, Reset, Clock);

BUFG bufg_inst(clk25, clk25_int); //Global Clock Buffer

wire [9:0] xpos;
wire [9:0] ypos;

video_timer video_timer_inst(clk25, Reset, hsync, vsync, xpos, ypos);
gameZybo game_inst(clk25, Reset, xpos, ypos, rota, rotb, red, green, blue);
					
endmodule
