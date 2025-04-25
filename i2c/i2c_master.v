module i2c_master #(
    parameter CLKS_PER_BIT      = 6,
    parameter CLKS_PER_BIT_HALF = 3
)(
    input       clk,
    input       reset,

    input [7:0] address_in,
    input [7:0] data_in,

    input       start_send,

    inout       sda,
    output reg  scl
);

//i2c master module. Currently unfinished

localparam IDLE         = 3'b000,
           START        = 3'b001,
           SEND_ADDRESS = 3'b010,
           SEND_DATA    = 3'b011,
           READ_DATA    = 3'b100,
           WAIT_ACK     = 3'b101,
           STOP         = 3'b110;

reg [2:0] state;
reg [3:0] bit_idx;
reg [7:0] clk_count;
reg [7:0] data_to_send;
reg       sda_out;
reg [7:0] data_to_read; //Register to store read data
reg [7:0] address;

assign sda = (state == IDLE || state == STOP || state == READ_DATA) ? 1'bz : sda_out;

always @(posedge clk) begin
    if (reset) begin
        state        <= IDLE;
        scl          <= 1'b1;
        sda_out      <= 1'b1;
        bit_idx      <= 4'b0;
        clk_count    <= 8'b0;
        data_to_send <= 8'b0;
        data_to_read <= 8'b0;
        address      <= 8'b0;
    end else begin
        case (state)
            IDLE: begin
                if (start_send) begin
                    state        <= START;
                    data_to_send <= data_in;
                    address      <= address_in;
                end
                scl     <= 1'b1;
                sda_out <= 1'b1;
            end

            START: begin
                if (clk_count == CLKS_PER_BIT_HALF) begin
                    sda_out   <= 1'b0;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    state     <= SEND_ADDRESS;
                    scl       <= 1'b0;
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            SEND_ADDRESS: begin
                if (clk_count < CLKS_PER_BIT_HALF) begin
                    sda_out <= address[7-bit_idx];
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT_HALF) begin
                    scl <= 1'b1;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    if (bit_idx == 7) begin
                        state <= WAIT_ACK;
                        bit_idx <= 4'b0;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                    scl <= 1'b0;
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            SEND_DATA: begin
                if (clk_count < CLKS_PER_BIT_HALF) begin
                    sda_out <= data_to_send[7-bit_idx];
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT_HALF) begin
                    scl <= 1'b1;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    if (bit_idx == 7) begin
                        state <= STOP;
                        bit_idx <= 4'b0;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                    scl <= 1'b0;
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            WAIT_ACK: begin
                if (clk_count < CLKS_PER_BIT_HALF) begin
                    sda_out <= 1'b1; // Release SDA
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT_HALF) begin
                    scl <= 1'b1;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    state <= SEND_DATA;
                    scl <= 1'b0;
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            READ_DATA: begin
                if (clk_count < CLKS_PER_BIT_HALF) begin
                    scl       <= 1'b0; //Keep SCL low for setup time
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT_HALF) begin
                    scl                  <= 1'b1; //Raise SCL for sampling SDA
                    data_to_read[7-bit_idx] <= sda; //Sample SDA into register
                    clk_count            <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    if (bit_idx == 7) begin
                        state   <= STOP; //Transition to STOP after reading all bits
                        bit_idx <= 4'b0;
                    end else begin
                        bit_idx <= bit_idx + 1;
                    end
                    scl       <= 1'b0; //Lower SCL for next bit setup
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            STOP: begin
                if (clk_count < CLKS_PER_BIT_HALF) begin
                    sda_out <= 1'b0;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT_HALF) begin
                    scl <= 1'b1;
                    clk_count <= clk_count + 1;
                end else if (clk_count == CLKS_PER_BIT) begin
                    sda_out <= 1'b1;
                    state <= IDLE;
                    clk_count <= 8'b0;
                end else begin
                    clk_count <= clk_count + 1;
                end
            end
        endcase
    end
end

endmodule
