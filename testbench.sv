`timescale 1ns/1ps

// `include "driving_4_anodes_TB.v"
// `include "baud_controller_TB.v"
// `include "uart_transmitter_receiver_TB.v"

module System_TB ();
  
  reg clk_TB, reset_TB;
  
  wire [3:0] AN_TB;
  wire [6:0] LED_TB;
  reg [15:0] sensor_DATA_TB;
  
  System DUT (clk_TB, reset_TB, sensor_DATA_TB, AN_TB, LED_TB);
  
//   driving_4_anodes_TB driving_4_anodes_TB (clk_TB, reset_TB);
//   baud_controller_TB baud_controller_TB (clk_TB, reset_TB);
//   uart_transmitter_receiver_TB uart_transmitter_receiver_TB (clk_TB, reset_TB);
  
  initial clk_TB = 1'b0;
  always #10 clk_TB = ~clk_TB;
  
  initial
    begin
      		reset_TB = 1'b0;
      #15	reset_TB = 1'b1;
    end
  
  initial
    begin
      $dumpfile("dump.vcd"); $dumpvars;
      #10000000 $finish;      
    end
  
  initial sensor_DATA_TB = 16'h3F5A;
  
endmodule