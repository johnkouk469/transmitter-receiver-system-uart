#!/usr/bin/env bash
# Runs every testbench of the project with Icarus Verilog and prints a summary.
#   ./run_sim.sh            uses -g2012 (default)
#   STD=2005 ./run_sim.sh   uses -g2005
# Results:
#   PASS        a check ran and passed
#   FAIL        a check ran and failed (unexpected)
#   SKIP        not run with this standard
#   COMPILE-OK  the component testbench compiles; it has no clock, reset or checks of its own (it is meant to be instantiated from a testbench that supplies them)
# Needs: iverilog and vvp (tested with Icarus Verilog 12.0). Output goes to ./build/.
set -u
cd "$(dirname "$0")"
STD="${STD:-2012}"
OUT=build
mkdir -p "$OUT"
rc=0
summary=""

compile_only() {   # name, top, file
  if iverilog -g"$STD" -s "$2" -o "$OUT/$1.vvp" "$3" 2> "$OUT/$1.log"; then
    summary+="COMPILE-OK  $1 (component testbench: needs a clock and reset from a parent testbench)"$'\n'
  else
    summary+="FAIL        $1 (does not compile, see $OUT/$1.log)"$'\n'; rc=1
  fi
}

run_check() {      # name, top, files...
  local name=$1 top=$2; shift 2
  if ! iverilog -g"$STD" -s "$top" -o "$OUT/$name.vvp" "$@" 2> "$OUT/$name.log"; then
    summary+="FAIL        $name (does not compile, see $OUT/$name.log)"$'\n'; rc=1; return
  fi
  ( cd "$OUT" && timeout 170 vvp "$name.vvp" > "$name.out" 2>&1 )
  if grep -q "^CHECK_PASS" "$OUT/$name.out"; then
    summary+="PASS        $name"$'\n'
  elif grep -q "^CHECK_FAIL" "$OUT/$name.out"; then
    summary+="FAIL        $name (see $OUT/$name.out)"$'\n'; rc=1
  else
    summary+="FAIL        $name (no verdict, see $OUT/$name.out)"$'\n'; rc=1
  fi
}

# Component testbenches
compile_only baud_controller_TB            baud_controller_TB            baud_controller_TB.v
compile_only driving_4_anodes_TB           driving_4_anodes_TB           driving_4_anodes_TB.v
compile_only uart_transmitter_receiver_TB  uart_transmitter_receiver_TB  uart_transmitter_receiver_TB.v

# Top-level testbench (testbench.sv) observed by a monitor
# (the monitor uses SystemVerilog final blocks, so it needs -g2012)
if [ "$STD" = 2012 ]; then
  run_check system_display   check_system            design.sv testbench.sv added_checks/check_system.sv
else
  summary+="SKIP        system_display (monitor needs -g2012; design.sv and testbench.sv do compile with -g2005)"$'\n'
fi

# Self-checking tests
run_check uart_loopback    check_uart_loopback     uart_transmitter.v uart_receiver.v added_checks/check_uart_loopback.sv
run_check rx_parity_error  check_rx_parity_error   uart_receiver.v baud_controller.v added_checks/check_rx_parity_error.sv
run_check rx_framing_error check_rx_framing_error  uart_receiver.v baud_controller.v added_checks/check_rx_framing_error.sv
run_check baud_rates       check_baud_rates        baud_controller.v added_checks/check_baud_rates.sv

echo "iverilog -g$STD summary"
printf '%s' "$summary"
exit $rc
