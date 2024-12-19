`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 03:49:05
// Design Name: 
// Module Name: smart_counter_2s
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


module smart_counter_2s(
    input clk_1Hz,
    input count_trigger,
    output reg [31:0] count = 0
    );
    
always @ (negedge clk_1Hz) begin
        if (count_trigger == 1) begin                          //first button press condition
            count <= (count == 32'd3) ? 32'd3 : count+1;       //counts for 2s the moment a button press is detected
        end
        if (count_trigger == 0) begin
            count <= 32'd0;                                    //resets count
        end
end
endmodule
