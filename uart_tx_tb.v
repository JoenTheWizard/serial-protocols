module uart_tx_test;

reg clk;
reg reset;
reg uart_tx_start;
reg [7:0] uart_tx_input;
wire uart_txd;

uart_tx uut(
    .clk(clk),
    .reset(reset),
    .uart_tx_start(uart_tx_start),
    .uart_tx_input(uart_tx_input),
    .uart_txd(uart_txd)
);

always #1 clk = ~clk;

initial begin
    $dumpfile("build/uart_tx.vcd"); //Assume in 'build' directory
    $dumpvars(0, uart_tx_test);

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
