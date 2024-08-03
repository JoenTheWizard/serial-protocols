//                             ____       ____
//  CPOL = 0      SCLK________|    |_____|    |___
//
//                    ________      _____      ___
//  CPOL = 1      SCLK        |____|     |____|        
//
//  CPOL will modify the SCLK polarity depending on the input parameter.
//
//  TODO:
//  - Create CPHA (Clock phase) parameter
//  - Utilize MISO (Master In Slave Out) signal when receiving from slave device
//
//  Source(s):
//  https://hackaday.io/project/119133-rops/log/144622-starting-with-verilog-and-spi
//
module spi_master #(
    parameter CLKS_PER_BIT = 20,
    parameter CLKS_PER_BIT_HALF = 10,
    parameter CPOL = 0
)(
    input       clk,
    input       reset,

    input [7:0] data_in,
    input       start_send,

    input       miso,
    output reg  mosi,
    output reg  cs,
    output reg  sclk
);

localparam SEND_IDLE  = 1'b0,
           SEND_DATA  = 1'b1;
reg [1:0] state;

//Bit counters and shift registers
reg [3:0]  bit_idx;
reg [15:0] bit_duration;
reg [7:0]  data_in_reg;

always @(posedge clk) begin
    //Reset states
    if (reset) begin
        state        <= SEND_IDLE; 
        cs           <= 1;
        mosi         <= 0;
        sclk         <= (CPOL == 0) ? 0 : 1;
        bit_idx      <= 4'b0;
        bit_duration <= 16'b0;
        data_in_reg  <= 0;
    end
    else begin
        //SPI states
        case (state)
            SEND_IDLE: begin
                if (start_send) begin
                    state        <= SEND_DATA;
                    cs           <= 0;
                    bit_duration <= 0;
                    data_in_reg  <= data_in;
                end
                else begin 
                    cs   <= 1;
                    sclk <= (CPOL == 0) ? 0 : 1;
                    mosi <= 0;
                end
            end

            SEND_DATA: begin
                if (bit_duration == CLKS_PER_BIT_HALF) begin
                    sclk         <= (CPOL == 0) ? 1 : 0;
                    bit_duration <= bit_duration + 1;
                    bit_idx      <= bit_idx; 
                    state        <= state;
                end
                else if (bit_duration == CLKS_PER_BIT) begin                    
                    if (bit_idx == 7) begin
                        state <= SEND_IDLE;
                        bit_idx <= 0;
                        bit_duration <= 0;
                        sclk <= sclk; 
                    end
                    else begin
                        sclk         <= (CPOL == 0) ? 0 : 1;
                        bit_duration <= 0;
                        bit_idx      <= bit_idx + 1;
                        state        <= state;
                    end 
                end 
                else begin
                    sclk         <= sclk;
                    bit_idx      <= bit_idx;
                    bit_duration <= bit_duration + 1;
                    mosi         <= data_in_reg[bit_idx];
                end
            end

        endcase
    end
end

endmodule
