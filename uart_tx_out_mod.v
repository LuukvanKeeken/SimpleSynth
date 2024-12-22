`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.12.2024 21:17:41
// Design Name: 
// Module Name: uart_tx_old
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx_out_mod (
    input wire clk,           // System clock
    input wire [7:0] data,    // 8-bit data to transmit
    input wire start,         // Start transmission signal
    output reg ready,         // Ready to accept new data
    output reg tx             // UART transmit line
);

    parameter BAUD_RATE = 115200;          // Desired baud rate
    parameter CLOCK_FREQ = 100_000_000; // System clock frequency (100 MHz)

    localparam BAUD_COUNT = CLOCK_FREQ / BAUD_RATE;  // Clock ticks per bit

    reg [$clog2(BAUD_COUNT)-1:0] baud_cnt;  // Counter for baud rate timing
    reg [3:0] bit_idx;                      // Bit index for serial data
    reg [9:0] shift_reg;                    // Shift register for UART frame
    reg tx_active;                          // Transmission state flag

    always @(posedge clk) begin
        if (!tx_active) begin
            if (start) begin
                // Prepare UART frame: [Start bit | Data bits | Stop bit]
                shift_reg <= {1'b1, data, 1'b0};  // Stop bit, data, start bit
                bit_idx <= 0;
                baud_cnt <= 0;
                tx_active <= 1;
                ready <= 0;  // Not ready while transmitting
            end else begin
                tx <= 1;  // Idle state
                ready <= 1;  // Ready to accept new data
            end
        end else begin
            // Transmitting
            if (baud_cnt == BAUD_COUNT - 1) begin
                tx <= shift_reg[0];  // Transmit the next bit
                shift_reg <= shift_reg >> 1;  // Shift to next bit
                bit_idx <= bit_idx + 1;
                baud_cnt <= 0;

                if (bit_idx == 9) begin
                    // End of frame
                    tx_active <= 0;
                    ready <= 1;
                end
            end else begin
                baud_cnt <= baud_cnt + 1;  // Count for baud timing
            end
        end
    end
endmodule