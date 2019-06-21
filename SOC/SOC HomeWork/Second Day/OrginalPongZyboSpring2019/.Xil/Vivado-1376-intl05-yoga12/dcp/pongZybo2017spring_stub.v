// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module pongZybo2017spring(Clock, Reset, rota, rotb, red, green, blue, hsync, vsync);
  input Clock;
  input Reset;
  input rota;
  input rotb;
  output [4:0]red;
  output [5:0]green;
  output [4:0]blue;
  output hsync;
  output vsync;
endmodule
