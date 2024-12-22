`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.12.2024 17:39:26
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input [3:0] sw,
    input [3:0] btn,
    output led,
    output wire uart_tx_out
    );
    
    
    reg [7:0] wave_data;
    wire uart_ready;
    reg uart_start;

    
    wire wave_val;
    reg [27:0] half_wave_period;
    
    
    wire deb_btn0_up, deb_btn1_up, deb_btn2_up, deb_btn3_up;
    wire deb_btn0, deb_btn1, deb_btn2, deb_btn3;
    debounce deb_inst0 (.clk(clk), .in(btn[0]), .out(deb_btn0), .onup(deb_btn0_up));
    debounce deb_inst1 (.clk(clk), .in(btn[1]), .out(deb_btn1), .onup(deb_btn1_up));
    debounce deb_inst2 (.clk(clk), .in(btn[2]), .out(deb_btn2), .onup(deb_btn2_up));
    debounce deb_inst3 (.clk(clk), .in(btn[3]), .out(deb_btn3), .onup(deb_btn3_up));
    
    
    
    
    always @(posedge clk) begin
        casex ({sw[3:0], deb_btn3, deb_btn2, deb_btn1, deb_btn0})
            8'b00000001: half_wave_period <= 191_110; // MIDDLE c
            8'b00000010: half_wave_period <= 180_388; // C#
            8'b00000100: half_wave_period <= 170_265; // D
            8'b00001000: half_wave_period <= 160_705; // D#
            8'b00010001: half_wave_period <= 151_685; // E
            8'b00010010: half_wave_period <= 143_172; // F
            8'b00010100: half_wave_period <= 135_139; // F#
            8'b00011000: half_wave_period <= 127_551; // G
            8'b001X0001: half_wave_period <= 120_395; // G#
            8'b001X0010: half_wave_period <= 113_636; // A440
            8'b001X0100: half_wave_period <= 107_259; // A#
            8'b001X1000: half_wave_period <= 101_239; // B
            8'b01XX0001: half_wave_period <= 95_557;  // C
            8'b01XX0010: half_wave_period <= 90_192;  // C#
            8'b01XX0100: half_wave_period <= 85_131;  // D
            8'b01XX1000: half_wave_period <= 80_354;  // D#
            8'b1XXX0001: half_wave_period <= 75_843;  // E
            8'b1XXX0010: half_wave_period <= 71_586;  // F
            8'b1XXX0100: half_wave_period <= 67_568;  // F#
            8'b1XXX1000: half_wave_period <= 63_776;  // G
            default: half_wave_period <= 28'hFFFFFFF;
        endcase
    end
    
    
    
    square_wave square_wave_inst (.clk(clk), .half_wave_period(half_wave_period), .wave_val(wave_val));
    
    assign led = wave_val;
    
    
    uart_tx_out_mod uart_tx_out_mod_inst (
        .clk(clk),               // Connect the system clock
        .data(wave_data),        // Send the sine data to UART
        .start(uart_start),      // Start signal for UART transmission
        .ready(uart_ready),      // Signal indicating UART is ready to transmit
        .tx(uart_tx_out)             // UART TX line output (for sending data)
    );

    // Control logic for UART transmission
    always @(posedge clk) begin
        if (uart_ready) begin
            uart_start <= 1;  // Trigger UART transmission when ready
        end else begin
            uart_start <= 0;  // Reset UART start when transmission completes
        end
        wave_data <= {7'b0, wave_val};
    end
   
endmodule