`timescale 1ns / 1ps


module debounce (
    input  wire  clk,   // clock
    input  wire  in,    // signal input
    output reg  out,   // signal output (debounced)
    output reg onup   // on up (one tick)
    );

    // sync with clock and combat metastability
    reg sync_0, sync_1;
    always @(posedge clk) sync_0 <= in;
    always @(posedge clk) sync_1 <= sync_0;

    reg [19:0] cnt;  // 2^20 = 10 ms counter at 100 MHz
    reg idle, max;
    always @(*) begin
        idle = (out == sync_1);
        max  = &cnt;
        onup = ~idle & max & out;
    end

    always @(posedge clk) begin
        if (idle) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            if (max) out <= ~out;
        end
    end
endmodule
