module spi_master_test;

//Testbench signals
reg       clk;
reg       reset;
reg [7:0] data_in;
reg       start_send;
reg       miso;
wire      mosi;
wire      cs;
wire      sclk;

spi_master uut(
    .clk(clk),
    .reset(reset),

    .data_in(data_in),
    .start_send(start_send),

    .miso(miso),
    .mosi(mosi),
    .cs(cs),
    .sclk(sclk)
);

always #1 clk = ~clk;

initial begin
    $dumpfile("build/spi_master.vcd"); //Assume in 'build' directory
    $dumpvars(0, spi_master_test);

    //Initialize signals
    clk = 0;
    reset = 1;
    data_in = 8'h00;
    start_send = 0;
    miso = 0;

    #20

    reset = 0;

    #10
    
    //Test case 1: Send a byte 0xA5
    data_in = 8'hAA;
    start_send = 1;

    #20
    start_send = 0;
    
    #320 
    data_in = 8'h34;
    start_send = 1;
    
    #10

    start_send = 0;
    #500

    $finish();
end

endmodule