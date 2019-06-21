//File Name: I2C_BaudRateGenerator.v
//Author: Jianjian Song
//Date: Oc 2017
//ECE333, Fall 2015
//Inputs: Baud Rate in BaudRate, System Clock Frequency in ClockFrequency
//Output: ClockI2C is a square wave
//-------------------------------------------------------------------
module ClockGenerator (OutClockFrequency, InputClockFrequency, OutClock, Reset, clock);
input Reset, clock;
input [9:0] OutClockFrequency;  //up to 1,000,000
input [9:0] InputClockFrequency; //up to 1GHz
output reg OutClock;

reg [9:0] 	baud_count;

 always @(posedge clock)
      if(Reset==1) begin baud_count <= 20'b0;
                    OutClock<=0;
					end
		else 
            if (baud_count < (InputClockFrequency/(OutClockFrequency*2)-1)) 
           		begin baud_count <= baud_count + 1'b1;
           		            OutClock<=OutClock;
                end
       else
		begin
				baud_count <= 16'b0;
      	     	OutClock <= ~OutClock;
      	end
endmodule
