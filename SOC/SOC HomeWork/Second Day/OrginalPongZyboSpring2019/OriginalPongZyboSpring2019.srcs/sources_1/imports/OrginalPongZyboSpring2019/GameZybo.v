`timescale 1ns / 1ps
// -----------------------------------------------
// updates the ball and paddle positions, and
// determines the output video image
// -----------------------------------------------

//Revised to work on Zybo board
//Jianjian Song
//Date: March 2017
//added Reset to the circuit
module gameZybo(input clk25, input Reset,
				input [9:0] xpos,
				input [9:0] ypos,
				input rota,
				input rotb,
				output [4:0] red,
				output [5:0] green,
				output [4:0] blue);
		
// paddle movement		
reg [8:0] paddlePosition;
reg [2:0] quadAr, quadBr;
always @(posedge clk25) quadAr <= {quadAr[1:0], rota};
always @(posedge clk25) quadBr <= {quadBr[1:0], rotb};

always @(posedge clk25)
if(quadAr[2] ^ quadAr[1] ^ quadBr[2] ^ quadBr[1])
begin
	if(quadAr[2] ^ quadBr[1]) begin
		if(paddlePosition < 508)        // make sure the value doesn't overflow
			paddlePosition <= paddlePosition + 3'd4;
	end
	else begin
		if(paddlePosition > 3)        // make sure the value doesn't underflow
			paddlePosition <= paddlePosition - 3'd4;
	end
end
		
// paddle2 movement		
reg [8:0] paddle2Position;
reg [2:0] quadAr2, quadBr2;
always @(posedge clk25) quadAr2 <= {quadAr2[1:0], rota};
always @(posedge clk25) quadBr2 <= {quadBr2[1:0], rotb};

always @(posedge clk25)
if(quadAr2[2] ^ quadAr2[1] ^ quadBr2[2] ^ quadBr2[1])
begin
	if(quadAr2[2] ^ quadBr2[1]) begin
		if(paddle2Position < 508)        // make sure the value doesn't overflow
			paddle2Position <= paddle2Position + 3'd4;
	end
	else begin
		if(paddle2Position > 3)        // make sure the value doesn't underflow
			paddle2Position <= paddle2Position - 3'd4;
	end
end

// ball movement	
reg [9:0] ballX;
reg [8:0] ballY;
reg ballXdir, ballYdir;
reg bounceX, bounceY;
	
wire endOfFrame = (xpos == 0 && ypos == 480);
	
always @(posedge clk25) begin
	if (endOfFrame) begin // update ball position at end of each frame
		if (ballX == 0 && ballY == 0) begin // cheesy reset handling, assumes initial value of 0
			ballX <= 480;
			ballY <= 300;
		end
		else begin
			if (ballXdir ^ bounceX) 
				ballX <= ballX + 5'd2;
			else 
				ballX <= ballX - 5'd2;	

			if (ballYdir ^ bounceY) 
				ballY <= ballY + 5'd2;
			else
				ballY <= ballY - 5'd2;	
		end
	end	
end		
		
// pixel color	
//reg [9:0] paddleLength = 300
reg [10:0] missTimer;	
wire visible = (xpos < 640 && ypos < 480);
wire top = (visible && ypos <= 3);
wire bottom = (visible && ypos >= 476);
wire left = (visible && xpos <= 3);
wire right = (visible && xpos >= 636);
wire border = (visible && (left || right || top));
wire paddle = (xpos >= paddlePosition+4 && xpos <= paddlePosition+124 && ypos >= 440 && ypos <= 447);
wire paddle2 = (xpos >= paddlePosition+4 && xpos <= paddlePosition+124 && ypos >= 40 && ypos <= 47);
wire ball = (xpos >= ballX && xpos <= ballX+7 && ypos >= ballY && ypos <= ballY+7);
wire background = (visible && !(border || paddle || ball));
wire checkerboard = (xpos[5] ^ ypos[5]);
wire ballcenter = ((ypos == ballY +3));
wire scoreTop = ((ypos == 10) && ballcenter ); //&& ballYdir);
wire scoreBottom = ((ypos==470) && ballcenter);// && !ballYdir);

//wire missed = visible && missTimer != 0;
wire missed = 0;
reg [3:0] FirstNumber,SecondNumber;

reg FirstOneReg,FirstTwoReg,FirstThreeReg,FirstFourReg,FirstFiveReg,FirstSixReg,FirstSevenReg;
reg SecondOneReg,SecondTwoReg,SecondThreeReg,SecondFourReg,SecondFiveReg,SecondSixReg,SecondSevenReg;

initial begin
    FirstNumber = 4'b0001;
    SecondNumber = 4'b0001;
    FirstOneReg = 1;
    FirstTwoReg = 1;
    FirstThreeReg = 1;
    FirstFourReg = 1;
    FirstFiveReg = 1;
    FirstSixReg = 1;
    FirstSevenReg = 1;
    
    SecondOneReg = 1;
    SecondTwoReg = 1;
    SecondThreeReg = 1;
    SecondFourReg = 1;
    SecondFiveReg = 1;
    SecondSixReg = 1;
    SecondSevenReg = 1;
end

wire FirstOne = (xpos >= 50 && xpos <= 60 && ypos >= 200 && ypos <= 280 && FirstOneReg);
wire FirstTwo = (xpos >= 60 && xpos <= 120 && ypos >= 200 && ypos <= 220 && FirstTwoReg);
wire FirstThree = (xpos >= 120 && xpos <= 130 && ypos >= 200 && ypos <= 280 && FirstThreeReg);
wire FirstFour = (xpos >= 60 && xpos <= 120 && ypos >= 270 && ypos <= 285 && FirstFourReg);
wire FirstFive = (xpos >= 60 && xpos <= 120 && ypos >= 345 && ypos <= 360 && FirstFiveReg);
wire FirstSix = (xpos >= 50 && xpos <= 60 && ypos >= 280 && ypos <= 360 && FirstSixReg);
wire FirstSeven = (xpos >= 120 && xpos <= 130 && ypos >= 280 && ypos <= 360 && FirstSevenReg);

wire First = FirstOne || FirstTwo || FirstThree || FirstFour || FirstFive || FirstSix || FirstSeven;

wire SecondOne = (xpos >= 390 && xpos <= 400 && ypos >= 200 && ypos <= 280 && SecondOneReg);
wire SecondTwo = (xpos >= 400 && xpos <= 460 && ypos >= 200 && ypos <= 220 && SecondTwoReg);
wire SecondThree = (xpos >= 460 && xpos <= 470 && ypos >= 200 && ypos <= 280 && SecondThreeReg);
wire SecondFour = (xpos >= 400 && xpos <= 460 && ypos >= 270 && ypos <= 285 && SecondFourReg);
wire SecondFive = (xpos >= 400 && xpos <= 460 && ypos >= 345 && ypos <= 360&& SecondFiveReg );
wire SecondSix = (xpos >= 390 && xpos <= 400 && ypos >= 280 && ypos <= 360 && SecondSixReg);
wire SecondSeven = (xpos >= 460 && xpos <= 470 && ypos >= 280 && ypos <= 360 && SecondSevenReg);

wire Second = SecondOne || SecondTwo || SecondThree || SecondFour || SecondFive || SecondSix || SecondSeven;


always @(posedge clk25) begin
       case (FirstNumber)
        4'b0000: begin 
             FirstOneReg = 1;
             FirstTwoReg = 1;
             FirstThreeReg = 1;
             FirstFourReg = 1;
             FirstFiveReg = 0;
             FirstSixReg = 1;
             FirstSevenReg = 1;
             end
               
        4'b0001: begin 
               FirstOneReg = 0;
               FirstTwoReg = 0;
               FirstThreeReg = 1;
               FirstFourReg = 0;
               FirstFiveReg = 0;
               FirstSixReg = 0;
               FirstSevenReg = 1;
              end
                  
        4'b0010: begin 
               FirstOneReg = 0;
               FirstTwoReg = 1;
               FirstThreeReg = 1;
               FirstFourReg = 1;
               FirstFiveReg = 1;
               FirstSixReg = 1;
               FirstSevenReg = 0;
             end
                         
        4'b0011: begin 
                FirstOneReg = 0;
                FirstTwoReg = 1;
                FirstThreeReg = 1;
                FirstFourReg = 1;
                FirstFiveReg = 1;
                FirstSixReg = 0;
                FirstSevenReg = 1;
            end
            
         4'b0101: begin 
                 FirstOneReg = 1;
                 FirstTwoReg = 1;
                 FirstThreeReg = 0;
                 FirstFourReg = 1;
                 FirstFiveReg = 1;
                 FirstSixReg = 0;
                 FirstSevenReg = 1;
            end                 
        
         4'b0110: begin 
                 FirstOneReg = 1;
                 FirstTwoReg = 1;
                 FirstThreeReg = 0;
                 FirstFourReg = 1;
                 FirstFiveReg = 1;
                 FirstSixReg = 1;
                 FirstSevenReg = 1;
            end     
                
         4'b0111: begin 
                 FirstOneReg = 0;
                 FirstTwoReg = 1;
                 FirstThreeReg = 1;
                 FirstFourReg = 0;
                 FirstFiveReg = 0;
                 FirstSixReg = 0;
                 FirstSevenReg = 1;
           end  
         
          4'b1001: begin 
                   FirstOneReg = 1;
                   FirstTwoReg = 1;
                   FirstThreeReg = 1;
                   FirstFourReg = 1;
                   FirstFiveReg = 0;
                   FirstSixReg = 0;
                   FirstSevenReg = 1;
             end 
 endcase
end


always @(posedge clk25) begin
       case (SecondNumber)
       4'b0000: begin 
            SecondOneReg = 1;
            SecondTwoReg = 1;
            SecondThreeReg = 1;
            SecondFourReg = 1;
            SecondFiveReg = 0;
            SecondSixReg = 1;
            SecondSevenReg = 1;
            end
              
      4'b0001: begin 
              SecondOneReg = 0;
              SecondTwoReg = 0;
              SecondThreeReg = 1;
              SecondFourReg = 0;
              SecondFiveReg = 0;
              SecondSixReg = 0;
              SecondSevenReg = 1;
             end
                 
      4'b010: begin 
              SecondOneReg = 0;
              SecondTwoReg = 1;
              SecondThreeReg = 1;
              SecondFourReg = 1;
              SecondFiveReg = 1;
              SecondSixReg = 1;
              SecondSevenReg = 0;
            end
                        
       4'b0011: begin 
               SecondOneReg = 0;
               SecondTwoReg = 1;
               SecondThreeReg = 1;
               SecondFourReg = 1;
               SecondFiveReg = 1;
               SecondSixReg = 0;
               SecondSevenReg = 1;
           end
           
        4'b0101: begin 
                SecondOneReg = 1;
                SecondTwoReg = 1;
                SecondThreeReg = 0;
                SecondFourReg = 1;
                SecondFiveReg = 1;
                SecondSixReg = 0;
                SecondSevenReg = 1;
           end                 

        4'b0110: begin 
                SecondOneReg = 1;
                SecondTwoReg = 1;
                SecondThreeReg = 0;
                SecondFourReg = 1;
                SecondFiveReg = 1;
                SecondSixReg = 1;
                SecondSevenReg = 1;
           end     
               
        4'b0111: begin 
                SecondOneReg = 0;
                SecondTwoReg = 1;
                SecondThreeReg = 1;
                SecondFourReg = 0;
                SecondFiveReg = 0;
                SecondSixReg = 0;
                SecondSevenReg = 1;
          end     
          
        4'b1001: begin 
              SecondOneReg = 1;
              SecondTwoReg = 1;
              SecondThreeReg = 1;
              SecondFourReg = 0;
              SecondFiveReg = 0;
              SecondSixReg = 1;
              SecondSevenReg = 1;
            end
endcase
end

//assign red   = { missed || border || paddle, 2'b00};	//3 bits red
assign red   = { missed&&(!paddle||!ball||!paddle2) || border || paddle || paddle2 || First || Second, missed&&(!paddle||!ball||!paddle2) || border || paddle || paddle2 || First || Second, 3'b000};	//5 bits red
assign green = { !missed && (border || paddle || ball || paddle2 || First || Second),  !missed && (border || paddle || ball || paddle2 || First || Second), 4'b0000};	//6 bits green
assign blue  = { !missed && (border || ball), background && checkerboard,background && checkerboard, 2'b00}; //5 bits blue
		
// ball collision	
always @(posedge clk25) begin
	if (!endOfFrame) begin
		if (ball && (left || right))
			bounceX <= 1;
			
		if (ball && (top || bottom || (paddle && ballYdir) || (paddle2 && !ballYdir))) begin
			bounceY <= 1;
			end
		
        if (scoreTop) begin
			FirstNumber =  (FirstNumber + 1);
            if(FirstNumber>9) begin
                FirstNumber <= 0;
                SecondNumber <= 0;
                end
            end
            
        if (scoreBottom) begin
            SecondNumber = (SecondNumber + 1);
            if(SecondNumber>9)begin
                FirstNumber <= 0;
                SecondNumber <= 0;
                //paddleLength <= paddleLegth /2;
                //if(
                end
            end
            
		//display missed screen for 63 frames
		if (ball && bottom || ball && top)
			missTimer <= 43;
	end
	else begin
		if (ballX == 0 && ballY == 0) begin // cheesy reset handling, assumes initial value of 0
			ballXdir <= 1;
			ballYdir <= 1;
			bounceX <= 0;
			bounceY <= 0;
		end 
		else begin
			if (bounceX)
				ballXdir <= ~ballXdir;
			if (bounceY)
				ballYdir <= ~ballYdir;			
			bounceX <= 0;
			bounceY <= 0;
			if (missTimer != 0)
				missTimer <= missTimer - 1'b1;
		end
	end
end
		
endmodule
