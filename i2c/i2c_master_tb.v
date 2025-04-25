module i2c_master_tb;

reg clk;
reg reset;
reg [7:0] address_in;
reg [7:0] data_in;
reg start_send;
wire sda;
wire scl;

//Instantiate the I2C master module
i2c_master #(
    .CLKS_PER_BIT(6),
    .CLKS_PER_BIT_HALF(3)
) uut (
    .clk(clk),
    .reset(reset),
    .address_in(address_in),
    .data_in(data_in),
    .start_send(start_send),
    .sda(sda),
    .scl(scl)
);

//Clock generation
always #5 clk = ~clk;

//Pullup resistors for I2C lines
pullup(sda);
pullup(scl);

initial begin
    $dumpfile("build/i2c_master.vcd");
    $dumpvars(0, i2c_master_tb);

    //Initialize inputs
    clk = 0;
    reset = 1;
    data_in = 8'h00;
    start_send = 0;

    //Reset the module
    #20 reset = 0;

    //Test case 1: Send a byte
    #20 address_in = 8'hB5; data_in = 8'hA2;
    #10 start_send = 1;
    #10 start_send = 0;

    // Wait for transmission to complete
    #2000;

    // Test case 2: Send another byte
    #20 data_in = 8'h3C;
    #10 start_send = 1;
    #10 start_send = 0;

    // Wait for transmission to complete
    #2000;

    $finish;
end

// Monitor I2C signals
initial begin
    $monitor("Time=%0t, SDA=%b, SCL=%b", $time, sda, scl);
end

endmodule
