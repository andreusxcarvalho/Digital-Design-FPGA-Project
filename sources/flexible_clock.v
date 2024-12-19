`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 15:32:32
// Design Name: 
// Module Name: flexible_clock
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


module flexible_clock(
    input basys3_clock,
    input [31:0] m,
    output reg my_clk = 0
    );
    
    reg [31:0] COUNT = 32'b0; //initialise the count as 32 bit 0 

    always @ (posedge basys3_clock) begin
        COUNT <= (COUNT == m [31:0]) ? 0 : COUNT+1; //increment the count and reset count when count reaches 7
        my_clk <= (COUNT == m [31:0]) ? ~my_clk : my_clk ; //switch high/low for slow clock only when count is reached
    end        
endmodule
