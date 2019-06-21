`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/04 14:48:12
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module comparitor4bits_TB;

reg[3:0] A,B;
wire AeqBbehavior,AgeqBbehavior,AltBbehavior;
comparaor4bits UnitBehavior
(A,B,AeqBbehavior,AgeBahavior,AltBbehavior);

inital begin
A=10;B=12;#5£»
A=5;B=12;#5;
A=8;B=8;#5;
A=12;B=10;#5;
A=10;B=5;#5;
A=0;B=0;#5;
A=3;B=3;#5;
A=20;B=12;#5;
$stop;
end
endmodule
