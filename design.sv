`timescale 1ns/1ps
`include "driving_4_anodes.v"
`include "uart_transmitter.v"
`include "uart_receiver.v"
module System (input wire clk, reset,
               input wire [15:0] sensor_DATA,
               output wire [3:0] AN,
               output wire [6:0] LED);
  
  // connections for trasmitter and receiver
  reg [2:0] baud_select;
  reg [7:0] Tx_DATA;
  reg Tx_WR, TX_EN, RX_EN, RxD;
  wire [7:0] Rx_DATA;
  wire TxD, TX_BUSY, Rx_FERROR, Rx_PERROR, Rx_VALID;
  
  // connections for LEDs
  reg [15:0] char_received;
  reg [15:0] char_toDisplay;
  
  reg word;
  
  reg [2:0] System_state;
  // state parameters
  parameter IDLE = 3'b000;
  parameter TRANSMIT = 3'b001;
  parameter RECEIVED = 3'b010;
  parameter DISPLAY = 3'b011;
  parameter TRANSMITION = 3'b100;
  
  uart_transmitter transmitter (clk, reset, baud_select, Tx_WR, TX_EN, Tx_DATA, TxD, TX_BUSY);
  
  uart_receiver receiver (clk, reset, baud_select, RX_EN, TxD, Rx_DATA, Rx_FERROR, Rx_PERROR, Rx_VALID);
  
  driving_4_anodes LEDs (AN, LED, clk, reset, char_toDisplay);
  
  initial
    begin
      baud_select = 3'b111;
      TX_EN = 0;
      RX_EN = 0;
//       TX_BUSY = 0;
      char_received = 16'hFFFF;
      char_toDisplay = 16'hFFFF;
      word = 0;
    end
  
  always @(sensor_DATA)
    begin
      word <= 0;
      System_state <= TRANSMIT;
    end
  
  
  
  always @(posedge clk or negedge reset)
    begin
      if (!reset)
        begin
          System_state <= TRANSMIT;
          word <= 0;
        end
      case (System_state)
        IDLE: begin
          TX_EN = 0;
          RX_EN = 0;
        end
        TRANSMIT: begin
          if (~TX_BUSY)
            begin
              if (word)
                Tx_DATA <= sensor_DATA[7:0];
              else
                Tx_DATA <= sensor_DATA[15:8];
              TX_EN <= 1;
              RX_EN <= 1;
              Tx_WR <= 1;
              System_state <= TRANSMITION;
            end
        end
        TRANSMITION: begin
          if (TX_BUSY)
            System_state <= RECEIVED;
        end
        RECEIVED: begin
          Tx_WR <= 0;
          if (~TX_BUSY)
            begin
              if (Rx_VALID)
                begin
                  if (word)
                    begin
                      char_received[7:0] <= Rx_DATA;
                      System_state <= DISPLAY;
                    end
                  else
                    begin                      
                      char_received[15:8] <= Rx_DATA;
                      word <= 1;
                      System_state <= TRANSMIT;
                    end                  
                end
              if (Rx_FERROR | Rx_PERROR)
                begin
                  char_received <= 16'hBBBB;
                  System_state <= DISPLAY;
                end
            end          
        end
        DISPLAY: begin
          char_toDisplay <= char_received;
          System_state <= IDLE;
        end
      endcase
    end
  
  
  
  
  
endmodule
        
        
  
  
  