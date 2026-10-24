// Self-checking test of the transmitter and receiver together.
// Self-checking loopback of the uart_transmitter and uart_receiver
// (TxD wired to RxD) for baud_select 000..111, four words each.
// Handshake only through Tx_WR / TX_BUSY, as the assignment text asks.
// Note: reset has no initial value on purpose; the design needs a real falling edge on reset (x to 0) to leave its unknown state.
`timescale 1ns/1ps
module check_uart_loopback;
  reg clk = 0, reset; reg [2:0] bs; reg [7:0] d; reg wr = 0, txen = 0, rxen = 0;
  wire txd, busy, fe, pe, v; wire [7:0] rd;
  uart_transmitter T(clk, reset, bs, wr, txen, d, txd, busy);
  uart_receiver    R(clk, reset, bs, rxen, txd, rd, fe, pe, v);
  always #10 clk = ~clk;
  integer i, k, errors = 0, frames = 0;
  reg [7:0] words [0:3];
  initial begin
    words[0] = 8'h3A; words[1] = 8'hA5; words[2] = 8'hFF; words[3] = 8'h00;
    for (k = 0; k < 8; k = k + 1) begin
      bs = k; reset = 0; wr = 0; txen = 0; rxen = 0; #55 reset = 1;
      for (i = 0; i < 4; i = i + 1) begin
        txen = 1; rxen = 1; d = words[i];
        @(posedge clk); wr = 1; @(posedge clk); wr = 0;
        wait (busy == 1); wait (busy == 0); #200;
        frames = frames + 1;
        if (!(rd === d && v === 1'b1 && fe === 1'b0 && pe === 1'b0)) begin
          errors = errors + 1;
          $display("CHECK_ERR baud_select=%b sent %h got %h valid=%b ferr=%b perr=%b", bs, d, rd, v, fe, pe);
        end
      end
    end
    $display("check_uart_loopback: %0d frames, %0d errors", frames, errors);
    if (errors == 0) $display("CHECK_PASS check_uart_loopback"); else $display("CHECK_FAIL check_uart_loopback errors=%0d", errors);
    $finish;
  end
endmodule
