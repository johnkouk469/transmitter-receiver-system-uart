`include "LEDdecoder.v"

module driving_4_anodes (output reg [3:0] AN,
                       output wire [6:0] LED,
                       input wire Clock, Reset,
                       input wire [15:0] fullChar);
  
  reg [3:0] count;
  reg [4:0] countOfAnode;
  
  reg [3:0] char_toDisplay;  
  LEDdecoder LEDdecoder (.char(char_toDisplay), .LED(LED));
  
  always @ (posedge Clock or negedge Reset)
    begin
      if (!Reset)
        count <= 4'b0;
      else
        if (&AN == 1)
        	count <= count + 1;
    end
  
  initial AN = 4'b1111;
  
  always @ (posedge Clock or negedge Reset)
    begin
      if (!Reset)
        countOfAnode <= 5'b0;
      else
        countOfAnode <= countOfAnode + 1;
    end
  
  always @ (AN)
    countOfAnode = 5'b0;
  
  always @ (countOfAnode)
    if (countOfAnode == 5'h10)
      AN = 4'hF;
        
  
  always @ (count)
    begin
      case(count)
        4'b0001: char_toDisplay = fullChar[15:12];
        4'b0011: AN[3] = 0;
        4'b0101: char_toDisplay = fullChar[11:8];
        4'b0111: AN[2] = 0;
        4'b1001: char_toDisplay = fullChar[7:4];
        4'b1011: AN[1] = 0;
        4'b1101: char_toDisplay = fullChar[4:0];
        4'b1111: AN[0] = 0;
        default : AN = 4'hF;
      endcase
    end
  
endmodule