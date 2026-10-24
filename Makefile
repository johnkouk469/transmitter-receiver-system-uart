# Convenience targets for Icarus Verilog.
#   make test           run every testbench and print PASS / FAIL
#   make test STD=2005  same with -g2005
#   make system         run the top-level testbench (testbench.sv), writes build/dump.vcd
#   make clean
STD ?= 2012

test:
	STD=$(STD) bash ./run_sim.sh

system:
	mkdir -p build
	iverilog -g$(STD) -s System_TB -o build/system.vvp design.sv testbench.sv
	cd build && vvp system.vvp

clean:
	rm -rf build

.PHONY: test system clean
