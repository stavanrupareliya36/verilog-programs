SIM ?= iverilog
BUILD := build
RTL := rtl/sync_fifo.sv
TB := tb/fifo_tb.sv

.PHONY: all test clean
all: test

$(BUILD):
	mkdir -p $(BUILD)

test: $(BUILD)
	$(SIM) -g2012 -Wall -s fifo_tb -o $(BUILD)/fifo_tb $(RTL) $(TB)
	vvp $(BUILD)/fifo_tb

clean:
	rm -rf $(BUILD)
