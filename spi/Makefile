BUILD_DIR=build

run_master: $(BUILD_DIR)
	iverilog spi_master* -o build/spi_master
	vvp build/spi_master
	gtkwave build/spi_master.vcd

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)