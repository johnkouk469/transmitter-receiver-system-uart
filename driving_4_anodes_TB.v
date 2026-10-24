`include "driving_4_anodes.v"

module driving_4_anodes_TB (input wire clk_TB, reset_TB);
  
  wire [3:0] AN_TB;
  wire [6:0] LED_TB;
  reg [15:0] char_TB;
  
  driving_4_anodes DUT (AN_TB, LED_TB, clk_TB, reset_TB, char_TB);
  
  initial 
    char_TB = 16'h1234;
  
endmodule