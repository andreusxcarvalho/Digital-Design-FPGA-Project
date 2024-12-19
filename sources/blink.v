`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 11:20:27
// Design Name: 
// Module Name: blink
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Flashes LED 0 and LED 15 at 10 Hz when respective switches are on.
// 
// Dependencies: flexible_clock module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module blink(
    input clk10,
    input p1_dying,
    input p2_dying,
    output [15:0] led // Remove `reg` here
);
    reg [15:0] led_reg;

    always @(posedge clk10) begin
        if (p2_dying) 
            led_reg[0] <= ~led_reg[0];
        else 
            led_reg[0] <= 0;

        if (p1_dying) 
            led_reg[15] <= ~led_reg[15];
        else 
            led_reg[15] <= 0;
    end

    assign led = led_reg; // Assign internal register to output wire
endmodule
