`timescale 1ns / 1ps


module square_wave(
    input clk,
    input [27:0] half_wave_period,
    output reg wave_val
    );
    
    
    initial begin
        wave_val = 0;
    end
    
    reg [26:0] counter = 27'b0;

    // Always block to increment counter on every rising clock edge
    always @(posedge clk) begin
        
        if (counter >= half_wave_period-1) begin
            wave_val = ~wave_val;
            counter = 0;
        end else begin
            counter <= counter + 1;
        end
    end
    
endmodule

