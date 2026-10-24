// Self-checking test of the baud rates.
// Measures the period of sample_ENABLE of the baud_controller for every baud_select,
// converts it to the baud rate (rate = 50 MHz / (16 * period)) and compares with the table
// of the assignment (300, 1200, 4800, 9600, 19200, 38400, 57600, 115200) with 2 % tolerance.
`timescale 1ns/1ps
module check_baud_rates;
  reg clk = 0, reset; reg [2:0] bs = 0; wire se;
  baud_controller B(reset, clk, bs, se);
  always #10 clk = ~clk;
  integer k, errors = 0; time t0, t1; real period, baud, target, err;
  initial begin
    for (k = 0; k < 8; k = k + 1) begin
      bs = k; reset = 0; #55 reset = 1;
      @(posedge se); t0 = $time; @(posedge se); @(posedge se); t1 = $time;
      period = (t1 - t0) / 2.0 / 20.0;
      baud = 50.0e6 / (16.0 * period);
      case (k) 0: target = 300; 1: target = 1200; 2: target = 4800; 3: target = 9600;
               4: target = 19200; 5: target = 38400; 6: target = 57600; default: target = 115200; endcase
      err = (baud - target) / target * 100.0;
      $display("baud_select=%b period=%0.0f cycles baud=%0.0f target=%0.0f error=%0.2f %%", bs, period, baud, target, err);
      if (err > 2.0 || err < -2.0) begin errors = errors + 1; $display("CHECK_ERR baud_select=%b outside 2 %% of table", bs); end
    end
    if (errors == 0) $display("CHECK_PASS check_baud_rates"); else $display("CHECK_FAIL check_baud_rates errors=%0d", errors);
    $finish;
  end
endmodule
