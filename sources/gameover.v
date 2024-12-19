`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 13:57:05
// Design Name: 
// Module Name: gameover
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


module gameover(
    input basys3_clk,
    input my_clk_25m,
    input [12:0] pixel_index_p1,
    input [12:0] pixel_index_p2,
    output reg [15:0] oled_color_P1,
    output reg [15:0] oled_color_P2,
    input [2:0] score1,
    input [2:0] score2
    );
    
    // OLED CONTENT: _____________________________________________________________
    wire [6:0] x_p1 = pixel_index_p1 % 96;  // x-coordinate (0-95)
    wire [5:0] y_p1 = pixel_index_p1 / 96;  // y-coordinate (0-63)
    wire [6:0] x_p2 = 95 - (pixel_index_p2 % 96); // x-coordinate (flipped horizontally)
    wire [5:0] y_p2 = 63 - (pixel_index_p2 / 96); // y-coordinate (flipped vertically for 46-pixel height)
    wire game_over_1;
    wire game_over_2;
    assign game_over_1 = 
            // "G" (shifted to the left)
            ((x_p1 >= 10 && x_p1 <= 17 && (y_p1 == 10 || y_p1 == 11)) || // Top horizontal
             (x_p1 == 10 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Left vertical
             (x_p1 >= 10 && x_p1 <= 17 && (y_p1 == 22 || y_p1 == 23)) || // Bottom horizontal
             (x_p1 == 17 && (y_p1 >= 16 && y_p1 <= 23)) ||               // Right vertical lower
             (x_p1 >= 14 && x_p1 <= 17 && (y_p1 == 16 || y_p1 == 17))) ||
    
            // "A" (shifted to the left)
            ((x_p1 == 20 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Left vertical
             (x_p1 == 24 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Right vertical
             (x_p1 >= 21 && x_p1 <= 23 && (y_p1 == 16 || y_p1 == 17)) || // Middle horizontal
             (x_p1 >= 21 && x_p1 <= 23 && (y_p1 == 10 || y_p1 == 11))) ||
    
            // "M" (shifted to the left)
            ((x_p1 == 27 && (y_p1 >= 10 && y_p1 <= 23)) || // Left vertical
             (x_p1 == 31 && (y_p1 >= 10 && y_p1 <= 23)) || // Right vertical
             (x_p1 == 28 && y_p1 == 12) ||                 // Left diagonal
             (x_p1 == 29 && y_p1 == 14) ||                 // Center diagonal
             (x_p1 == 30 && y_p1 == 12)) ||                // Right diagonal
    
            // "E" (shifted to the left)
            ((x_p1 == 34 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Left vertical
             (x_p1 >= 35 && x_p1 <= 41 && (y_p1 == 10 || y_p1 == 11)) || // Top horizontal
             (x_p1 >= 35 && x_p1 <= 39 && (y_p1 == 16 || y_p1 == 17)) || // Middle horizontal
             (x_p1 >= 35 && x_p1 <= 41 && (y_p1 == 22 || y_p1 == 23))) ||
    
            // "O" (shifted to the right)
            ((x_p1 >= 46 && x_p1 <= 53 && (y_p1 == 10 || y_p1 == 11)) || // Top horizontal
             (x_p1 == 46 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Left vertical
             (x_p1 == 53 && (y_p1 >= 10 && y_p1 <= 23)) ||               // Right vertical
             (x_p1 >= 46 && x_p1 <= 53 && (y_p1 == 22 || y_p1 == 23))) ||
    
            // "V" (shifted to the right)
            ((x_p1 == 56 && (y_p1 >= 10 && y_p1 <= 19)) ||                // Left diagonal
             (x_p1 == 57 && (y_p1 >= 20 && y_p1 <= 21)) || 
             (x_p1 == 58 && (y_p1 >= 22 && y_p1 <= 23)) || 
             (x_p1 == 60 && (y_p1 >= 22 && y_p1 <= 23)) ||                // Right diagonal
             (x_p1 == 61 && (y_p1 >= 20 && y_p1 <= 21)) || 
             (x_p1 == 62 && (y_p1 >= 10 && y_p1 <= 19))) ||
    
            // "E" (shifted to the right)
            ((x_p1 == 66 && (y_p1 >= 10 && y_p1 <= 23)) ||                // Left vertical
             (x_p1 >= 67 && x_p1 <= 73 && (y_p1 == 10 || y_p1 == 11)) ||  // Top horizontal
             (x_p1 >= 67 && x_p1 <= 71 && (y_p1 == 16 || y_p1 == 17)) ||  // Middle horizontal
             (x_p1 >= 67 && x_p1 <= 73 && (y_p1 == 22 || y_p1 == 23))) ||
    
            // "R" (shifted to the right)
            ((x_p1 == 76 && (y_p1 >= 10 && y_p1 <= 23)) ||                // Left vertical
             (x_p1 >= 77 && x_p1 <= 79 && (y_p1 == 10 || y_p1 == 11)) ||  // Top horizontal
             (x_p1 == 80 && (y_p1 >= 12 && y_p1 <= 15)) ||                // Right vertical upper
             (x_p1 >= 77 && x_p1 <= 79 && (y_p1 == 16 || y_p1 == 17)) ||  // Middle horizontal
             (x_p1 == 80 && (y_p1 == 18 || y_p1 == 19)) ||                // Right diagonal lower
             (x_p1 == 81 && (y_p1 == 20 || y_p1 == 21)) || 
             (x_p1 == 82 && (y_p1 == 22 || y_p1 == 23))); 
    assign game_over_2 = 
                     // "G" (shifted to the left)
                     ((x_p2 >= 10 && x_p2 <= 17 && (y_p2 == 10 || y_p2 == 11)) || // Top horizontal
                      (x_p2 == 10 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Left vertical
                      (x_p2 >= 10 && x_p2 <= 17 && (y_p2 == 22 || y_p2 == 23)) || // Bottom horizontal
                      (x_p2 == 17 && (y_p2 >= 16 && y_p2 <= 23)) ||               // Right vertical lower
                      (x_p2 >= 14 && x_p2 <= 17 && (y_p2 == 16 || y_p2 == 17))) ||
             
                     // "A" (shifted to the left)
                     ((x_p2 == 20 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Left vertical
                      (x_p2 == 24 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Right vertical
                      (x_p2 >= 21 && x_p2 <= 23 && (y_p2 == 16 || y_p2 == 17)) || // Middle horizontal
                      (x_p2 >= 21 && x_p2 <= 23 && (y_p2 == 10 || y_p2 == 11))) ||
             
                     // "M" (shifted to the left)
                     ((x_p2 == 27 && (y_p2 >= 10 && y_p2 <= 23)) || // Left vertical
                      (x_p2 == 31 && (y_p2 >= 10 && y_p2 <= 23)) || // Right vertical
                      (x_p2 == 28 && y_p2 == 12) ||                 // Left diagonal
                      (x_p2 == 29 && y_p2 == 14) ||                 // Center diagonal
                      (x_p2 == 30 && y_p2 == 12)) ||                // Right diagonal
             
                     // "E" (shifted to the left)
                     ((x_p2 == 34 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Left vertical
                      (x_p2 >= 35 && x_p2 <= 41 && (y_p2 == 10 || y_p2 == 11)) || // Top horizontal
                      (x_p2 >= 35 && x_p2 <= 39 && (y_p2 == 16 || y_p2 == 17)) || // Middle horizontal
                      (x_p2 >= 35 && x_p2 <= 41 && (y_p2 == 22 || y_p2 == 23))) ||
             
                     // "O" (shifted to the right)
                     ((x_p2 >= 46 && x_p2 <= 53 && (y_p2 == 10 || y_p2 == 11)) || // Top horizontal
                      (x_p2 == 46 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Left vertical
                      (x_p2 == 53 && (y_p2 >= 10 && y_p2 <= 23)) ||               // Right vertical
                      (x_p2 >= 46 && x_p2 <= 53 && (y_p2 == 22 || y_p2 == 23))) ||
             
                     // "V" (shifted to the right)
                     ((x_p2 == 56 && (y_p2 >= 10 && y_p2 <= 19)) ||                // Left diagonal
                      (x_p2 == 57 && (y_p2 >= 20 && y_p2 <= 21)) || 
                      (x_p2 == 58 && (y_p2 >= 22 && y_p2 <= 23)) || 
                      (x_p2 == 60 && (y_p2 >= 22 && y_p2 <= 23)) ||                // Right diagonal
                      (x_p2 == 61 && (y_p2 >= 20 && y_p2 <= 21)) || 
                      (x_p2 == 62 && (y_p2 >= 10 && y_p2 <= 19))) ||
             
                     // "E" (shifted to the right)
                     ((x_p2 == 66 && (y_p2 >= 10 && y_p2 <= 23)) ||                // Left vertical
                      (x_p2 >= 67 && x_p2 <= 73 && (y_p2 == 10 || y_p2 == 11)) ||  // Top horizontal
                      (x_p2 >= 67 && x_p2 <= 71 && (y_p2 == 16 || y_p2 == 17)) ||  // Middle horizontal
                      (x_p2 >= 67 && x_p2 <= 73 && (y_p2 == 22 || y_p2 == 23))) ||
             
                     // "R" (shifted to the right)
                     ((x_p2 == 76 && (y_p2 >= 10 && y_p2 <= 23)) ||                // Left vertical
                      (x_p2 >= 77 && x_p2 <= 79 && (y_p2 == 10 || y_p2 == 11)) ||  // Top horizontal
                      (x_p2 == 80 && (y_p2 >= 12 && y_p2 <= 15)) ||                // Right vertical upper
                      (x_p2 >= 77 && x_p2 <= 79 && (y_p2 == 16 || y_p2 == 17)) ||  // Middle horizontal
                      (x_p2 == 80 && (y_p2 == 18 || y_p2 == 19)) ||                // Right diagonal lower
                      (x_p2 == 81 && (y_p2 == 20 || y_p2 == 21)) || 
                      (x_p2 == 82 && (y_p2 == 22 || y_p2 == 23))); 

    
    
    always @(posedge my_clk_25m) begin
        if (score1 > score2) begin
            if (game_over_1) begin
                oled_color_P1 <= 16'h07E0; 
            end
            else begin
                oled_color_P1 <= 16'h0000; 
            end
            if (game_over_2) begin
                oled_color_P2 <= 16'hF800; // Red
            end
            else begin
                oled_color_P2 <= 16'h0000;
            end
        end
        else if (score1 < score2) begin
            if (game_over_1) begin
                oled_color_P1 <= 16'hF800; 
            end
            else begin
                oled_color_P1 <= 16'h0000;
            end
            if (game_over_2) begin
                oled_color_P2 <= 16'h07E0; // Red
            end
            else begin
                oled_color_P2 <= 16'h0000;
            end
        end else begin
            oled_color_P1 <= 16'h0000; 
            oled_color_P2 <= 16'h0000; 
        end
    end
    
endmodule

