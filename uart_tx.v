module uart_tx #(
    //Set Parameters
    //parameter BIT_RATE     = 9600,
    //parameter CLK_HZ       = 100000000,
    parameter CLKS_PER_BIT = 20 //CLK_HZ / BIT_RATE
)(
    input       clk,
    input       reset,
    input       uart_tx_start, //Transmit start
    input [7:0] uart_tx_input,
    output reg  uart_txd
);

//State machine states
parameter [1:0] IDLE  = 2'b00,
                START = 2'b01,
                DATA  = 2'b10,
                STOP  = 2'b11;
reg [1:0] state;

//Bit counters and shift registers
reg [3:0]  bit_idx;
reg [15:0] bit_duration;

always @(posedge clk) begin
    if (reset) begin 
        state        <= IDLE;
        uart_txd     <= 1'b1;
        bit_duration <= 0;
        bit_idx      <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                uart_txd  <= 1'b1;
                if (uart_tx_start) begin
                    state        <= START;
                    bit_duration <= 0;
                end
            end
            START: begin 
                uart_txd <= 0;
                bit_duration <= bit_duration + 1;
                if (bit_duration == CLKS_PER_BIT) begin
                    state <= DATA;
                    bit_duration <= 0;
                    bit_idx <= 0;
                end
            end
            DATA: begin
                uart_txd <= uart_tx_input[bit_idx];
                bit_duration <= bit_duration + 1;
                if (bit_duration == CLKS_PER_BIT) begin
                    bit_idx <= bit_idx + 1;
                    bit_duration <= 0;
                    if (bit_idx == 7) begin
                        state <= STOP;
                        bit_duration = 0;
                    end
                end
            end
            STOP: begin
                uart_txd <= 1;
                bit_duration <= bit_duration + 1;
                if (bit_duration == CLKS_PER_BIT) begin
                    state <= IDLE;
                    bit_duration <= 0;
                end
            end
        endcase
    end
end

endmodule