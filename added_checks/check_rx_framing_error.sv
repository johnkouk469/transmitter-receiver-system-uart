// Self-checking test of the receiver's framing error.
// The assignment says Rx_FERROR must be set when the stop bit is not 1 and
// should stay set until a new start bit. This test sends one frame with stop bit 0,
// checks that Rx_FERROR is set and held in the idle gap and that Rx_VALID stays low,
// then sends a good frame and checks that it is received correctly and clears Rx_FERROR.
`timescale 1ns/1ps
module check_rx_framing_error;
  reg clk = 0, reset, rxd = 1, rxen = 1; wire [7:0] rd; wire fe, pe, v;
  uart_receiver R(clk, reset, 3'b111, rxen, rxd, rd, fe, pe, v);
  always #10 clk = ~clk;
  localparam BIT = 8640;   // 16 * 27 clock cycles of 20 ns (115200 baud)
  integer i, errors = 0, fe_pulses = 0;
  always @(posedge fe) fe_pulses = fe_pulses + 1;
  initial begin
    reset = 0; #55 reset = 1; #(3*BIT);
    rxd = 0; #BIT; for (i = 0; i < 8; i = i + 1) begin rxd = (8'h3A >> i) & 1; #BIT; end
    rxd = ^8'h3A; #BIT; rxd = 0; #BIT; rxd = 1; #(2*BIT);
    $display("check_rx_framing_error: Rx_FERROR pulses seen=%0d, value in idle gap after frame=%b", fe_pulses, fe);
    if (fe !== 1'b1) begin errors = errors + 1; $display("CHECK_ERR Rx_FERROR not held after a bad stop bit"); end
    if (v !== 1'b0) begin errors = errors + 1; $display("CHECK_ERR Rx_VALID is %b after a frame with a bad stop bit", v); end
    // good frame after the bad one
    rxd = 0; #BIT; for (i = 0; i < 8; i = i + 1) begin rxd = (8'h5C >> i) & 1; #BIT; end
    rxd = ^8'h5C; #BIT; rxd = 1; #BIT; rxd = 1; #(2*BIT);
    if (!(rd === 8'h5C && v === 1'b1 && fe === 1'b0 && pe === 1'b0)) begin errors = errors + 1; $display("CHECK_ERR good frame after the bad one: data=%h valid=%b ferr=%b perr=%b", rd, v, fe, pe); end
    if (errors == 0) $display("CHECK_PASS check_rx_framing_error"); else $display("CHECK_FAIL check_rx_framing_error errors=%0d", errors);
    $finish;
  end
endmodule
