`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 17:24:02
// Design Name: 
// Module Name: roundover
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


module roundover(
    input basys3_clk,
    input my_clk_25m,
    input [12:0] pixel_index_p1,
    input [12:0] pixel_index_p2,
    output reg [15:0] oled_color_P1,
    output reg [15:0] oled_color_P2,
    input [1:0] green_block_count_p1,
    input [1:0] green_block_count_p2
    );
    
    wire [6:0] x_p1 = pixel_index_p1 % 96;  // x-coordinate (0-95)
    wire [5:0] y_p1 = pixel_index_p1 / 96;  // y-coordinate (0-63)
    wire [6:0] x_p2 = 95 - (pixel_index_p2 % 96); // x-coordinate (flipped horizontally)
    wire [5:0] y_p2 = 63 - (pixel_index_p2 / 96); // y-coordinate (flipped vertically for 46-pixel height)
    wire round_over_1;
    wire round_over_2;
    
    
    assign round_over_1 = 
            // "R" in "ROUND" (1.5x scaled and adjusted)
                ((x_p1 == 30 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Left vertical
                 (x_p1 >= 31 - 3 && x_p1 <= 36 - 3 && (y_p1 == 18 || y_p1 == 19)) ||       // Top horizontal
                 (x_p1 == 37 - 3 && (y_p1 >= 20 && y_p1 <= 24)) ||                  // Right vertical upper
                 (x_p1 >= 31 - 3 && x_p1 <= 36 - 3 && (y_p1 == 25 || y_p1 == 26)) ||       // Middle horizontal
                 (x_p1 == 37 - 3 && (y_p1 == 27 || y_p1 == 28)) ||                  // Right diagonal lower
                 (x_p1 == 38 - 3 && (y_p1 >= 29 && y_p1 <= 31))) ||                 // Right diagonal bottom
    
                // "O" in "ROUND" (more circular shape and scaled up)
                ((x_p1 >= 40 - 3 && x_p1 <= 46 - 3 && (y_p1 == 18 || y_p1 == 19)) ||       // Top horizontal
                 (x_p1 == 40 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Left vertical
                 (x_p1 == 46 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Right vertical
                 (x_p1 >= 40 - 3 && x_p1 <= 46 - 3 && (y_p1 == 30 || y_p1 == 31))) ||      // Bottom horizontal
    
                // "U" in "ROUND" (scaled up)
                ((x_p1 == 49 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Left vertical
                 (x_p1 == 55 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Right vertical
                 (x_p1 >= 50 - 3 && x_p1 <= 54 - 3 && (y_p1 == 30 || y_p1 == 31))) ||      // Bottom horizontal
    
                // "N" in "ROUND" (scaled up with more pixels)
                ((x_p1 == 58 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Left vertical
                 (x_p1 == 64 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Right vertical
                 (x_p1 == 59 - 3 && y_p1 == 20) ||                               // Left diagonal
                 (x_p1 == 60 - 3 && y_p1 == 22) || 
                 (x_p1 == 61 - 3 && y_p1 == 24) ||
                 (x_p1 == 62 - 3 && y_p1 == 26) || 
                 (x_p1 == 63 - 3 && y_p1 == 28)) ||
    
                // "D" in "ROUND" (scaled up and curved)
                ((x_p1 == 67 - 3 && (y_p1 >= 18 && y_p1 <= 31)) ||                  // Left vertical
                 (x_p1 >= 68 - 3 && x_p1 <= 73 - 3 && (y_p1 == 18 || y_p1 == 19)) ||       // Top horizontal
                ((x_p1 == 73 - 3 || x_p1 == 74 - 3) && (y_p1 == 20)) ||   // Right vertical (curved)
                ((x_p1 == 74 - 3 || x_p1 == 75 - 3) && (y_p1 == 21)) || // curve outwards for D
                ((x_p1 == 75 - 3 || x_p1 == 76 - 3) && (y_p1 == 22)) ||  // curve outwards for D
                 (x_p1 == 76 - 3 && (y_p1 == 23)) ||  // curve outwards for D
                 (x_p1 == 76 - 3 && (y_p1 >= 23 && y_p1 <= 27)) ||  // vertical straight line down for D
                ((x_p1 == 75 - 3 || x_p1 == 76 - 3) && (y_p1 == 27)) || // turn curve backwards now from D
                ((x_p1 == 74 - 3 || x_p1 == 75 - 3) && (y_p1 == 28)) || // turn curve backwards now from D
                ((x_p1 == 73 - 3 || x_p1 == 74 - 3) && (y_p1 == 29)) || // turn curve backwards now from D
                ((x_p1 == 73 - 3 || x_p1 == 72 - 3) && (y_p1 == 30)) || // turn curve backwards now from D
                 (x_p1 >= 68 - 3 && x_p1 <= 73 - 3 && (y_p1 == 30 || y_p1 == 31))) ||      // Bottom horizontal
    
                // "O" in "OVER" (scaled up and circular)
                ((x_p1 >= 30 && x_p1 <= 35 && (y_p1 == 36 || y_p1 == 37)) ||       // Top horizontal
                 (x_p1 == 30 && (y_p1 >= 36 && y_p1 <= 49)) ||                  // Left vertical
                 (x_p1 == 35 && (y_p1 >= 36 && y_p1 <= 49)) ||                  // Right vertical
                 (x_p1 >= 30 && x_p1 <= 35 && (y_p1 == 48 || y_p1 == 49))) ||      // Bottom horizontal
    
                // "V" in "OVER" (scaled up and enhanced)
                ((x_p1 == 38 && (y_p1 >= 36 && y_p1 <= 45)) ||                  // Left diagonal
                 (x_p1 == 39 && (y_p1 == 46 || y_p1 == 47)) || 
                 (x_p1 == 40 && (y_p1 == 48 || y_p1 == 49)) || 
                 (x_p1 == 41 && (y_p1 == 48 || y_p1 == 49)) || 
                 (x_p1 == 42 && (y_p1 == 48 || y_p1 == 49)) || 
                 (x_p1 == 43 && (y_p1 == 48 || y_p1 == 49)) ||                  // Center point
                 (x_p1 == 44 && (y_p1 == 46 || y_p1 == 47)) ||                  // Right diagonal
                 (x_p1 == 45 && (y_p1 >= 36 && y_p1 <= 45))) ||
    
                // "E" in "OVER" (scaled up)
                ((x_p1 == 49 && (y_p1 >= 36 && y_p1 <= 49)) ||                  // Left vertical
                 (x_p1 >= 50 && x_p1 <= 55 && (y_p1 == 36 || y_p1 == 37)) ||       // Top horizontal
                 (x_p1 >= 50 && x_p1 <= 53 && (y_p1 == 42 || y_p1 == 43)) ||       // Middle horizontal
                 (x_p1 >= 50 && x_p1 <= 55 && (y_p1 == 48 || y_p1 == 49))) ||      // Bottom horizontal
    
                // "R" in "OVER" (scaled up with more pixels)
                ((x_p1 == 58 && (y_p1 >= 36 && y_p1 <= 49)) ||                  // Left vertical
                 (x_p1 >= 59 && x_p1 <= 64 && (y_p1 == 36 || y_p1 == 37)) ||       // Top horizontal
                 (x_p1 == 63 && (y_p1 >= 38 && y_p1 <= 43)) ||                  // Right vertical upper
                 (x_p1 >= 59 && x_p1 <= 63 && (y_p1 == 44 || y_p1 == 45)) ||       // Middle horizontal
                 (x_p1 == 63 && (y_p1 == 46)) ||                  // Right diagonal lower
                 (x_p1 == 64 && y_p1 == 47) ||
                 (x_p1 == 65 && y_p1 == 48) || 
                 (x_p1 == 66 && y_p1 == 49));

             
    assign round_over_2 = 
                         // "R" in "ROUND" (1.5x scaled and adjusted)
                             ((x_p2 == 30 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Left vertical
                              (x_p2 >= 31 - 3 && x_p2 <= 36 - 3 && (y_p2 == 18 || y_p2 == 19)) ||       // Top horizontal
                              (x_p2 == 37 - 3 && (y_p2 >= 20 && y_p2 <= 24)) ||                  // Right vertical upper
                              (x_p2 >= 31 - 3 && x_p2 <= 36 - 3 && (y_p2 == 25 || y_p2 == 26)) ||       // Middle horizontal
                              (x_p2 == 37 - 3 && (y_p2 == 27 || y_p2 == 28)) ||                  // Right diagonal lower
                              (x_p2 == 38 - 3 && (y_p2 >= 29 && y_p2 <= 31))) ||                 // Right diagonal bottom
                 
                             // "O" in "ROUND" (more circular shape and scaled up)
                             ((x_p2 >= 40 - 3 && x_p2 <= 46 - 3 && (y_p2 == 18 || y_p2 == 19)) ||       // Top horizontal
                              (x_p2 == 40 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Left vertical
                              (x_p2 == 46 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Right vertical
                              (x_p2 >= 40 - 3 && x_p2 <= 46 - 3 && (y_p2 == 30 || y_p2 == 31))) ||      // Bottom horizontal
                 
                             // "U" in "ROUND" (scaled up)
                             ((x_p2 == 49 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Left vertical
                              (x_p2 == 55 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Right vertical
                              (x_p2 >= 50 - 3 && x_p2 <= 54 - 3 && (y_p2 == 30 || y_p2 == 31))) ||      // Bottom horizontal
                 
                             // "N" in "ROUND" (scaled up with more pixels)
                             ((x_p2 == 58 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Left vertical
                              (x_p2 == 64 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Right vertical
                              (x_p2 == 59 - 3 && y_p2 == 20) ||                               // Left diagonal
                              (x_p2 == 60 - 3 && y_p2 == 22) || 
                              (x_p2 == 61 - 3 && y_p2 == 24) ||
                              (x_p2 == 62 - 3 && y_p2 == 26) || 
                              (x_p2 == 63 - 3 && y_p2 == 28)) ||
                 
                             // "D" in "ROUND" (scaled up and curved)
                             ((x_p2 == 67 - 3 && (y_p2 >= 18 && y_p2 <= 31)) ||                  // Left vertical
                              (x_p2 >= 68 - 3 && x_p2 <= 73 - 3 && (y_p2 == 18 || y_p2 == 19)) ||       // Top horizontal
                             ((x_p2 == 73 - 3 || x_p2 == 74 - 3) && (y_p2 == 20)) ||   // Right vertical (curved)
                             ((x_p2 == 74 - 3 || x_p2 == 75 - 3) && (y_p2 == 21)) || // curve outwards for D
                             ((x_p2 == 75 - 3 || x_p2 == 76 - 3) && (y_p2 == 22)) ||  // curve outwards for D
                              (x_p2 == 76 - 3 && (y_p2 == 23)) ||  // curve outwards for D
                              (x_p2 == 76 - 3 && (y_p2 >= 23 && y_p2 <= 27)) ||  // vertical straight line down for D
                             ((x_p2 == 75 - 3 || x_p2 == 76 - 3) && (y_p2 == 27)) || // turn curve backwards now from D
                             ((x_p2 == 74 - 3 || x_p2 == 75 - 3) && (y_p2 == 28)) || // turn curve backwards now from D
                             ((x_p2 == 73 - 3 || x_p2 == 74 - 3) && (y_p2 == 29)) || // turn curve backwards now from D
                             ((x_p2 == 73 - 3 || x_p2 == 72 - 3) && (y_p2 == 30)) || // turn curve backwards now from D
                              (x_p2 >= 68 - 3 && x_p2 <= 73 - 3 && (y_p2 == 30 || y_p2 == 31))) ||      // Bottom horizontal
                 
                             // "O" in "OVER" (scaled up and circular)
                             ((x_p2 >= 30 && x_p2 <= 35 && (y_p2 == 36 || y_p2 == 37)) ||       // Top horizontal
                              (x_p2 == 30 && (y_p2 >= 36 && y_p2 <= 49)) ||                  // Left vertical
                              (x_p2 == 35 && (y_p2 >= 36 && y_p2 <= 49)) ||                  // Right vertical
                              (x_p2 >= 30 && x_p2 <= 35 && (y_p2 == 48 || y_p2 == 49))) ||      // Bottom horizontal
                 
                             // "V" in "OVER" (scaled up and enhanced)
                             ((x_p2 == 38 && (y_p2 >= 36 && y_p2 <= 45)) ||                  // Left diagonal
                              (x_p2 == 39 && (y_p2 == 46 || y_p2 == 47)) || 
                              (x_p2 == 40 && (y_p2 == 48 || y_p2 == 49)) || 
                              (x_p2 == 41 && (y_p2 == 48 || y_p2 == 49)) || 
                              (x_p2 == 42 && (y_p2 == 48 || y_p2 == 49)) || 
                              (x_p2 == 43 && (y_p2 == 48 || y_p2 == 49)) ||                  // Center point
                              (x_p2 == 44 && (y_p2 == 46 || y_p2 == 47)) ||                  // Right diagonal
                              (x_p2 == 45 && (y_p2 >= 36 && y_p2 <= 45))) ||
                 
                             // "E" in "OVER" (scaled up)
                             ((x_p2 == 49 && (y_p2 >= 36 && y_p2 <= 49)) ||                  // Left vertical
                              (x_p2 >= 50 && x_p2 <= 55 && (y_p2 == 36 || y_p2 == 37)) ||       // Top horizontal
                              (x_p2 >= 50 && x_p2 <= 53 && (y_p2 == 42 || y_p2 == 43)) ||       // Middle horizontal
                              (x_p2 >= 50 && x_p2 <= 55 && (y_p2 == 48 || y_p2 == 49))) ||      // Bottom horizontal
                 
                             // "R" in "OVER" (scaled up with more pixels)
                             ((x_p2 == 58 && (y_p2 >= 36 && y_p2 <= 49)) ||                  // Left vertical
                              (x_p2 >= 59 && x_p2 <= 64 && (y_p2 == 36 || y_p2 == 37)) ||       // Top horizontal
                              (x_p2 == 63 && (y_p2 >= 38 && y_p2 <= 43)) ||                  // Right vertical upper
                              (x_p2 >= 59 && x_p2 <= 63 && (y_p2 == 44 || y_p2 == 45)) ||       // Middle horizontal
                              (x_p2 == 63 && (y_p2 == 46)) ||                  // Right diagonal lower
                              (x_p2 == 64 && y_p2 == 47) ||
                              (x_p2 == 65 && y_p2 == 48) || 
                              (x_p2 == 66 && y_p2 == 49));

    
    
    always @(posedge my_clk_25m) begin

        if (round_over_1) begin
            if (green_block_count_p1 == 0) begin
                oled_color_P1 <= 16'b11111_000000_00000; // Red
            end
            else begin
                oled_color_P1 <= 16'b00000_111111_00000; // Green 
            end
        end
        else begin
            oled_color_P1 <= 16'h0000; 
        end
        if (round_over_2) begin
            if (green_block_count_p2 == 0) begin
                oled_color_P2 <= 16'b11111_000000_00000; // Red
            end
            else begin
                oled_color_P2 <= 16'b00000_111111_00000; // Green 
            end
            
        end
        else begin
            oled_color_P2 <= 16'h0000;
        end     
    end
    
endmodule

