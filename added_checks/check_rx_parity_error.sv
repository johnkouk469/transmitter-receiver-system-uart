// Self-checking test of the receiver's parity error.
// Drives RxD of the uart_receiver directly (baud_select 111) with good frames and
// frames with a wrong parity bit, including bad frames whose parity bit equals the
// parity bit of the frame before. Expected by the assignment: Rx_PERROR is raised
// for the bad-parity frames only.
`timescale 1ns/1ps
module check_rx_parity_error;
  reg clk = 0, reset, rxd = 1, rxen = 1; wire [7:0] rd; wire fe, pe, v;
  uart_receiver R(clk, reset, 3'b111, rxen, rxd, rd, fe, pe, v);
  always #10 clk = ~clk;
  localparam BIT = 8640;   // 16 * 27 clock cycles of 20 ns (115200 baud)
  integer errors = 0;
  task send(input [7:0] data, input par, input stop);
    integer i; begin
      rxd = 0; #BIT; for (i = 0; i < 8; i = i + 1) begin rxd = data[i]; #BIT; end
      rxd = par; #BIT; rxd = stop; #BIT; rxd = 1; #(2*BIT);
    end
  endtask
  initial begin
    reset = 0; #55 reset = 1; #(3*BIT);   // reset needs a falling edge, see report
    send(8'h3A, ^8'h3A, 1);
    if (!(rd === 8'h3A && v === 1 && pe === 0 && fe === 0)) begin errors = errors + 1; $display("CHECK_ERR good frame 1: data=%h valid=%b perr=%b ferr=%b", rd, v, pe, fe); end
    send(8'h3A, ~(^8'h3A), 1);
    if (pe !== 1'b1) begin errors = errors + 1; $display("CHECK_ERR bad-parity frame not flagged: perr=%b", pe); end
    send(8'h5C, ^8'h5C, 1);
    if (!(rd === 8'h5C && v === 1 && pe === 0 && fe === 0)) begin errors = errors + 1; $display("CHECK_ERR good frame 2: data=%h valid=%b perr=%b ferr=%b", rd, v, pe, fe); end
    // Same parity bit as the frame before, wrong for the data: 5C has even parity (bit 0), so the bit 0 is right and 01 with bit 0 is wrong.
    send(8'h01, 1'b0, 1);
    if (pe !== 1'b1) begin errors = errors + 1; $display("CHECK_ERR bad parity with unchanged parity bit (after good frame) not flagged: perr=%b", pe); end
    send(8'h01, 1'b0, 1);
    if (pe !== 1'b1) begin errors = errors + 1; $display("CHECK_ERR bad parity with unchanged parity bit (after bad frame) not flagged: perr=%b", pe); end
    send(8'h7E, ^8'h7E, 1);
    if (!(rd === 8'h7E && v === 1 && pe === 0 && fe === 0)) begin errors = errors + 1; $display("CHECK_ERR good frame 3: data=%h valid=%b perr=%b ferr=%b", rd, v, pe, fe); end
    if (errors == 0) $display("CHECK_PASS check_rx_parity_error"); else $display("CHECK_FAIL check_rx_parity_error errors=%0d", errors);
    $finish;
  end
endmodule
