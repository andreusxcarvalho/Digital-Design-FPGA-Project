`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 15:07:29
// Design Name: 
// Module Name: tick
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


module tick(
    input my_clk_25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_color,
    input flip
    );
    
    reg [6:0] coordinate_x;
    reg [5:0] coordinate_y; 

    always @(posedge my_clk_25m) begin
        if (!flip) begin
            coordinate_x  = pixel_index % 96;  // x-coordinate (0-95)
            coordinate_y  = pixel_index / 96;  // y-coordinate (0-63)
        end
        else begin
            coordinate_x = 95 - (pixel_index % 96); // x-coordinate (flipped horizontally)
            coordinate_y = 63 - (pixel_index / 96); // y-coordinate (flipped vertically for 46-pixel height)
        end
        // Assign statement to display a green tick on the OLED
        oled_color = (
            // Left diagonal line (bottom-left to center, overlaps center by 1 pixel)
            ((coordinate_x >= coordinate_y + 9) && (coordinate_x <= coordinate_y + 14) &&
             (coordinate_x >= 10) && (coordinate_x <= 48) && (coordinate_y >= 10) && (coordinate_y <= 32)) ||
        
            // Right diagonal line (center to bottom-right, overlaps center by 1 pixel)
            ((coordinate_x >= 80 - coordinate_y + 9) && (coordinate_x <= 80 - coordinate_y + 14) &&
             (coordinate_x >= 48) && (coordinate_x <= 86) && (coordinate_y >= 32) && (coordinate_y <= 54))
        ) ? 16'b00000_111111_00000 : 16'b00000_000000_00000;
        
        if (coordinate_x > 10 && coordinate_x <= 85 && coordinate_y >= 10 && coordinate_y <=54) begin
            if ((coordinate_x + 4 == coordinate_y - 10) || (coordinate_x == 94 - coordinate_y)) begin
                oled_color = 16'b00000_111111_00000;
            end
            else begin
                oled_color = 16'b00000_000000_00000;
            end
        end
        else begin 
            oled_color = 16'b00000_000000_00000;
        end




    end
endmodule

