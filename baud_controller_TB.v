`include "baud_controller.v"

module baud_controller_TB (input wire clk_TB, reset_TB);
  
  reg [2:0] baud_select_TB;
  wire sample_ENABLE_TB;
  
  baud_controller DUT (reset_TB, clk_TB, baud_select_TB, sample_ENABLE_TB); 
  
  initial
    baud_select_TB = 3'b111;        
  
endmodule