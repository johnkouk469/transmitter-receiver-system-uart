`include "baud_controller.v"

module uart_transmitter(input wire clk, reset,
                        input wire [2:0] baud_select,
                        input wire Tx_WR, TX_EN,
                        input wire [7:0] Tx_DATA,
                        output reg TxD, TX_BUSY);

  wire Tx_sample_ENABLE;
  
  baud_controller baud_controller_tx_instance(reset, clk, baud_select, Tx_sample_ENABLE);
  
  reg [3:0] counter;
  reg [3:0] bitsSent;
  reg [2:0] state;
  reg parity;
  
  // UART parameters
  parameter IDLE = 3'b000;
  parameter START = 3'b001;
  parameter DATA = 3'b010;
  parameter PARITY = 3'b011;
  parameter STOP = 3'b100;
  
  initial counter = 0;
  
  always @(Tx_DATA)
    parity = ^(Tx_DATA[7:0]);
  
  always @(posedge clk)
    begin
      if(TX_EN)
        begin
          if(state == IDLE)
            begin
              TxD <= 1;
              bitsSent <= 0;
              if(Tx_WR)
                begin
                  state <= START;
                  TX_BUSY <= 1;
//                   Tx_WR <= 0;
                  counter <= 0;                  
                end
            end
        end
    end
  
  always @(posedge Tx_sample_ENABLE or negedge reset)
    begin
      if (!reset)
      begin
        state <= IDLE;
        TX_BUSY <= 0;
      end
      if (TX_EN)
        begin
          case(state)
//             IDLE: begin
//               TxD <= 1;
//               bitsSent <= 0;
//               if(Tx_WR)
//                 begin
//                   state <= START;
//                   TX_BUSY <= 1;
// //                   Tx_WR <= 0;
//                   counter <= 0;                  
//                 end
//             end
            START: begin
              TxD <= 0;
              if (counter == 15)
                begin
                  state <= DATA;
                  bitsSent <= bitsSent + 1;
                end
              else
                state <= START;
            end
            DATA: begin
              if(bitsSent == 9)
                state <= PARITY;
              else
                begin
                  TxD <= Tx_DATA[bitsSent-1];
                  if(counter == 15)
                    bitsSent <= bitsSent + 1;
                end
            end
            PARITY: begin
              TxD <= parity;
              if (counter == 15)
                state <= STOP;
            end
            STOP: begin
              TxD <= 1;
              if(counter == 15)
                begin
                  bitsSent <= bitsSent + 1;
                  TX_BUSY <= 0;
                  state <= IDLE;
                end
            end
          endcase
        end
    end  
  
  always @(posedge Tx_sample_ENABLE)
    counter <= counter + 1;
  
endmodule