BUILD_DIR=build

run_tx: $(BUILD_DIR)
	iverilog uart_tx* -o build/uart_tx
	vvp build/uart_tx
	gtkwave build/uart_tx.vcd

run_rx: $(BUILD_DIR)
	iverilog uart_rx_tb.v uart_rx.v uart_tx.v -o build/uart_rx
	vvp build/uart_rx
	gtkwave build/uart_rx.vcd

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)