module uart_rx_test;

reg clk;
reg reset;
reg uart_tx_start;
reg [7:0] uart_tx_input;
wire uart_txd;

wire uart_err;
wire [7:0] uart_rx_data;
wire uart_valid;

uart_tx uut(
    .clk(clk),
    .reset(reset),
    .uart_tx_start(uart_tx_start),
    .uart_tx_input(uart_tx_input),
    .uart_txd(uart_txd)
);

uart_rx uut1(
    .clk(clk),
    .reset(reset),
    .uart_rxd(uart_txd),
    .uart_rx_data(uart_rx_data),
    .uart_err(uart_err),
    .uart_valid(uart_valid)
);

always #1 clk = ~clk;

initial begin
    $dumpfile("build/uart_rx.vcd"); //Assume in 'build' directory
    $dumpvars(0, uart_rx_test);

    clk = 0;
    reset = 1;
    #200
    reset = 0;

    #2

    //Test case 1
    uart_tx_input = 'h34;

    #2

    uart_tx_start = 1;

    #2

    uart_tx_start = 0;

    #700

    //Test case 2
    uart_tx_input = 'h55;

    #2

    uart_tx_start = 1;

    #2

    uart_tx_start = 0;

    #2000

    $finish();
end

endmodule
