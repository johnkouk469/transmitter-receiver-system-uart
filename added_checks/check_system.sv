// Self-checking monitor for the top-level testbench System_TB (testbench.sv).
// It does not drive any signal of the design; it only observes.
// Checks: (1) anodes never overlap, (2) each anode is low for 320 ns,
// (3) the LED pattern at each anode matches the decoder output for that nibble
//         of the displayed word (checked after 160 us, when the word is stable),
// (4) at the end of the run the displayed word equals the sensor word that was sent.
`timescale 1ns/1ps
module check_system;
  System_TB t();
  integer errors = 0, scans = 0;
  real t_fall [0:3];
  reg [3:0] prevAN = 4'hF;
  reg [3:0] nib;
  wire [6:0] exp_led;
  LEDdecoder dec (.char(nib), .LED(exp_led));
  integer i;
  always @(t.AN_TB) begin
    if (!$isunknown(t.AN_TB) && ($countones(~t.AN_TB)) > 1) begin errors = errors + 1; $display("CHECK_ERR overlap AN=%b at %0t", t.AN_TB, $time); end
    for (i = 0; i < 4; i = i + 1) begin
      if (prevAN[i] && !t.AN_TB[i]) begin
        t_fall[i] = $realtime;
        if ($time > 160000) begin
          nib = t.DUT.char_toDisplay[4*i +: 4];
          #0;
          scans = scans + 1;
          if (t.LED_TB !== exp_led) begin errors = errors + 1; $display("CHECK_ERR LED=%b expected %b for AN[%0d] at %0t", t.LED_TB, exp_led, i, $time); end
        end
      end
      if (!prevAN[i] && t.AN_TB[i]) begin
        if (($realtime - t_fall[i]) != 320.0) begin errors = errors + 1; $display("CHECK_ERR AN[%0d] low for %0f ns (expected 320)", i, $realtime - t_fall[i]); end
      end
    end
    prevAN = t.AN_TB;
  end
  final begin
    if (t.DUT.char_toDisplay !== t.sensor_DATA_TB) begin errors = errors + 1; $display("CHECK_ERR displayed word %h != sensor word %h", t.DUT.char_toDisplay, t.sensor_DATA_TB); end
    if (scans < 100) begin errors = errors + 1; $display("CHECK_ERR too few scans checked: %0d", scans); end
    $display("check_system: %0d digit scans checked, displayed word %h, sensor word %h", scans, t.DUT.char_toDisplay, t.sensor_DATA_TB);
    if (errors == 0) $display("CHECK_PASS check_system"); else $display("CHECK_FAIL check_system errors=%0d", errors);
  end
endmodule
