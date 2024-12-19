`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2024 15:02:52
// Design Name: 
// Module Name: smart_counter_200m
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


module smart_counter_50m(
    input clk_1KHz,
    input count_trigger,
    output reg [31:0] count = 0
    );
    
always @ (negedge clk_1KHz) begin
        if (count_trigger == 1) begin                          //first button press condition
            count <= (count == 32'd50) ? 32'b1 : count+1;       //counts for 50 milliseconds the moment a button press is detected
        end
        if (count_trigger == 0) begin
            count <= 32'd0;                                    //freezes count
        end
end
endmodule
