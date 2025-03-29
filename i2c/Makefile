I2C_FILE = i2c_master.v i2c_master_tb.v
BUILD 	 = build

all: builddir
	iverilog -o $(BUILD)/i2c_simulation $(I2C_FILE)

builddir:
	mkdir -p build

clean:
	rm -rf $(BUILD)
