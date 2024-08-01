module uart_rx #(
    //Set Parameters
    parameter BIT_RATE     = 9600,
    parameter CLK_HZ       = 100000000,
    parameter CLKS_PER_BIT = CLK_HZ / BIT_RATE //Parameter set manually for simulation purposes
)(
    input            clk,
    input            reset,
    input            uart_rxd,
    output reg [7:0] uart_rx_data, //Received data
    output reg       uart_err,
    output reg       uart_valid
);

//Half cycle to sample bit
parameter CLKS_PER_BIT_HALF = CLKS_PER_BIT / 2;

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
        bit_duration <= 0;
        bit_idx      <= 0;
        uart_rx_data <= 8'b0;
        uart_err     <= 0;
        uart_valid   <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                uart_err = 1'b0;
                uart_valid = 1'b0;
                if (uart_rxd == 1'b0) begin
                    state        <= START;
                    bit_duration <= 1'b0;
                end
            end
            START: begin
                bit_duration <= bit_duration + 1;
                if (bit_duration == CLKS_PER_BIT_HALF - 1) begin
                    if (uart_rxd == 1'b0) begin
                        state <= DATA;
                        bit_idx <= 0;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
            end
            DATA: begin
                if (bit_duration == CLKS_PER_BIT - 1) begin
                    uart_rx_data[bit_idx] <= uart_rxd;
                    bit_duration <= 0;
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 7) begin
                        state <= STOP;
                        bit_duration = 0;
                    end
                end
                else begin 
                   bit_duration <= bit_duration + 1;
                end 
            end
            STOP: begin
                bit_duration <= bit_duration + 1;
                if (bit_duration == CLKS_PER_BIT - 1) begin
                    if (uart_rxd == 1'b1) begin
                        state <= IDLE;
                        uart_valid <= 1'b1;
                    end
                    else begin
                        uart_err <= 1'b1;
                        state <= IDLE;
                    end
                end
            end
        endcase
    end
end

endmodule
