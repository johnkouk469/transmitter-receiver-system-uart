`include "uart_transmitter.v"
`include "uart_receiver.v"

module uart_transmitter_receiver_TB (input wire clk_TB, reset_TB);
  
  reg [2:0] baud_select_TB;
  reg [7:0] Tx_DATA_TB;
  reg Tx_WR_TB, TX_EN_TB, RX_EN_TB, RxD_TB;
  wire [7:0] Rx_DATA_TB;
  wire TxD_TB, TX_BUSY_TB, Rx_FERROR_TB, Rx_PERROR_TB, Rx_VALID_TB;
  
  uart_transmitter DUT_transmitter (clk_TB, reset_TB, baud_select_TB, Tx_WR_TB, TX_EN_TB, Tx_DATA_TB, TxD_TB, TX_BUSY_TB);
  
  uart_receiver DUT_receiver (clk_TB, reset_TB, baud_select_TB, RX_EN_TB, TxD_TB, Rx_DATA_TB, Rx_FERROR_TB, Rx_PERROR_TB, Rx_VALID_TB);
  
  initial
    begin
      TX_EN_TB = 1;
      RX_EN_TB = 1;
      baud_select_TB = 3'b111;
//       Tx_DATA_TB = 8'b10101010;
      Tx_DATA_TB = 8'h3A;
    end
  
  initial
    begin
      		Tx_WR_TB = 1'b0;
      #20	Tx_WR_TB = 1'b1;
      #40   Tx_WR_TB = 1'b0;
    end
  
endmodule