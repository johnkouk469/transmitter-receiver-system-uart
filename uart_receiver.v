// `include "baud_controller.v"

module uart_receiver(input wire clk, reset,
                     input wire [2:0] baud_select,
                     input wire RX_EN, RxD,
                     output reg [7:0] Rx_DATA,
                     output reg Rx_FERROR, Rx_PERROR, Rx_VALID);
  
  baud_controller baud_controller_rx_instance (reset, clk, baud_select, Rx_sample_ENABLE);
  
  reg [3:0] counter;
  reg [3:0] bitsReceived;
  reg [2:0] state;
  
  // UART parameters
  parameter IDLE = 3'b000;
  parameter START = 3'b001;
  parameter DATA = 3'b010;
  parameter PARITY = 3'b011;
  parameter STOP = 3'b100;
  parameter BREAK = 3'b101;
  
  initial counter = 0; 
  
  
  
  always @(posedge clk)
    begin
      if(RX_EN)
        begin
          if(state == IDLE)
            begin
              bitsReceived <= 0;
              if(~RxD)
                begin
                  state <= START;
                  counter <= 0;
                  Rx_DATA <= 8'b0;
                  Rx_FERROR <= 0;
                  Rx_PERROR <= 0;
                  Rx_VALID <= 0;
                end
            end
        end
    end
  
  always @(posedge Rx_sample_ENABLE or negedge reset)
    begin
      if (!reset)
        begin
          state <= IDLE;
          Rx_VALID <= 1;
        end
      if (RX_EN)
        begin
          case (state)
//             IDLE: begin
//               bitsReceived <= 0;
//               if(~RxD)
//                 begin
//                   state <= START;
//                   counter <= 0;
//                   Rx_DATA <= 8'b0;
//                   Rx_FERROR <= 0;
//                   Rx_PERROR <= 0;
//                   Rx_VALID <= 0;
//                 end
// //               else
// //                 state <= IDLE;
//             end
            START: begin
              if (counter == 7)
                begin
                  state <= DATA;
                  counter <= 0;
                  bitsReceived <= 1;
                end
            end
            DATA: begin
              if (bitsReceived == 9)
                state <= PARITY;
              if (counter == 15)
                begin
                  state <= DATA;
                  Rx_DATA[bitsReceived-1] <= RxD;
                  bitsReceived <= bitsReceived + 1;
                end
            end
            PARITY: begin
              if (counter == 15)
                begin
                  Rx_PERROR <= (^Rx_DATA != RxD);
                  state <= STOP;
                  bitsReceived <= bitsReceived + 1;
                end
            end
            STOP: begin
              if (counter == 15)
                begin
                  bitsReceived <= bitsReceived + 1;
                  state <= IDLE;
                  if(RxD == 1)
                    Rx_VALID <= 1;
                  else
                    begin
                      Rx_FERROR <= 1;
                      state <= BREAK;
                    end
                end
            end
            BREAK: begin
              if (RxD)
                state <= IDLE;
            end
          endcase
        end
    end
  
  always @(posedge Rx_sample_ENABLE)
    counter <= counter + 1;
  
endmodule