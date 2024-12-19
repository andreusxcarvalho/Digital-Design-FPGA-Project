`timescale 1ns / 1ps

module quiz_mode(
    input basys3_clk,
    input my_clk_25m, 
    input my_clk_6p25m,   
    input quiz_reset,      
    input [15:0] sw,
    output [3:0] an,
    output [6:0] seg,
    input [12:0] pixel_index_p1,
    input [12:0] pixel_index_p2,
    output reg [15:0] oled_color_P1,
    output reg [15:0] oled_color_P2,
    output reg correct_status_p1,
    output reg correct_status_p2,
    input restart
    );
    
    // All OLED COORDINATE: _________________________________________________________
    wire [6:0] x_p1 = pixel_index_p1 % 96;  // x-coordinate (0-95)
    wire [5:0] y_p1 = pixel_index_p1 / 96;  // y-coordinate (0-63)
    
    wire [6:0] x_p2 = 95 - (pixel_index_p2 % 96); // x-coordinate (flipped horizontally)
    wire [5:0] y_p2 = 63 - (pixel_index_p2 / 96); // y-coordinate (flipped vertically for 46-pixel height)

    // ______________________________________________________________________________
    
    function [15:0] calculate_color;
        input [7:0] user_input;           // User's binary input (decimal_value)
        input [7:0] random_number;        // Random generated number (random_number_out)
    
        reg [7:0] difference;
        reg [7:0] normalized_diff;
        reg [4:0] red_level;
        reg [5:0] green_level;
    
        begin
            // Calculate absolute difference between user input and random number
            difference = (user_input > random_number) ? (user_input - random_number) : (random_number - user_input);
    
            // Normalize difference to a range of 0-255
            normalized_diff = (difference * 127) / 127; // Normalized difference
    
            // Calculate red and green levels for RGB565 format
            red_level = (31 * normalized_diff) / 127;            // 5-bit red (0-31)
            green_level = (63 * (127 - normalized_diff)) / 127;  // 6-bit green (0-63)
    
            // Create the color with red decreasing as green increases
            calculate_color = (red_level << 11) | (green_level << 5);
        end
    endfunction
    function [15:0] draw_digit;
        input [6:0] centre_x;  // Center X of the 7-segment digit
        input [5:0] centre_y;  // Center Y of the 7-segment digit
        input [3:0] number;    // Digit to display (0-9)
        input [6:0] x;         // Current X coordinate on OLED
        input [5:0] y;         // Current Y coordinate on OLED
        input [15:0] current_color;
        
        reg [6:0] x_left, x_right, x_middle;  // X positions for left, right, and middle segments
        reg [5:0] y_top, y_middle, y_bottom;  // Y positions for top, middle, and bottom segments
        reg [6:0] segment_active;             // Bitmask for active segments
        
        begin
            // Calculate positions for each segment based on centre_x and centre_y
            x_left   = centre_x - 10;  // Left side of vertical segments (f, e)
            x_right  = centre_x + 9;   // Right side of vertical segments (b, c)
            x_middle = centre_x - 7;   // Horizontal segments (a, g, d) at middle
            y_top    = centre_y - 20;  // Top (segment a)
            y_middle = centre_y - 2;   // Middle (segment g)
            y_bottom = centre_y + 18;  // Bottom (segment d)
    
            // Lookup table for digit-to-segment mapping
            // Each bit corresponds to a segment: g f e d c b a (bit 6 to bit 0)
            case (number)
                4'd0: segment_active = 7'b1111110;  // Segments: a, b, c, d, e, f
                4'd1: segment_active = 7'b0110000;  // Segments: b, c
                4'd2: segment_active = 7'b1101101;  // Segments: a, b, g, e, d
                4'd3: segment_active = 7'b1111001;  // Segments: a, b, c, d, g
                4'd4: segment_active = 7'b0110011;  // Segments: f, g, b, c
                4'd5: segment_active = 7'b1011011;  // Segments: a, f, g, c, d
                4'd6: segment_active = 7'b1011111;  // Segments: a, f, e, d, c, g
                4'd7: segment_active = 7'b1110000;  // Segments: a, b, c
                4'd8: segment_active = 7'b1111111;  // Segments: a, b, c, d, e, f, g
                4'd9: segment_active = 7'b1111011;  // Segments: a, b, c, d, f, g
                default: segment_active = 7'b0000000;  // Invalid number, no segments
            endcase
    
            // Draw the segments based on the active bitmask
            if (segment_active[6] && (x >= x_middle && x <= x_middle + 13 && y >= y_top && y <= y_top + 3)) begin
                draw_digit = current_color;  // Segment a (top horizontal) - Green
            end else if (segment_active[5] && (x >= x_right && x <= x_right + 3 && y >= y_top && y <= y_middle)) begin
                draw_digit = current_color;  // Segment b (top-right vertical) - Green
            end else if (segment_active[4] && (x >= x_right && x <= x_right + 3 && y >= y_middle + 3 && y <= y_bottom)) begin
                draw_digit = current_color;  // Segment c (bottom-right vertical) - Green
            end else if (segment_active[3] && (x >= x_middle && x <= x_middle + 13 && y >= y_bottom && y <= y_bottom + 3)) begin
                draw_digit = current_color;  // Segment d (bottom horizontal) - Green
            end else if (segment_active[2] && (x >= x_left && x <= x_left + 3 && y >= y_middle + 3 && y <= y_bottom)) begin
                draw_digit = current_color;  // Segment e (bottom-left vertical) - Green
            end else if (segment_active[1] && (x >= x_left && x <= x_left + 3 && y >= y_top && y <= y_middle)) begin
                draw_digit = current_color;  // Segment f (top-left vertical) - Green
            end else if (segment_active[0] && (x >= x_middle && x <= x_middle + 13 && y >= y_middle && y <= y_middle + 3)) begin
                draw_digit = current_color;  // Segment g (middle horizontal) - Green
            end else begin
                draw_digit = 16'b0000000000000000;  // Background color (Black)
            end

        end
    endfunction
    
    // Mutual
    wire [7:0] random_number_out;
    
    random_number rng(
            .CLOCK(basys3_clk),
            .trigger(sw[15]), // change from 0 to 1 or 1 to 0
            .random_out(random_number_out) // Wire for the latest number
    );
    seven_segment_display display(
            .CLOCK(basys3_clk),
            .number(random_number_out),
            .an(an),
            .seg(seg)
    );
    
   

    
    // P1
    wire [7:0] decimal_value_p1 = sw[6:0];
    wire [3:0] hundreds_p1 = (decimal_value_p1 / 100) % 10;
    wire [3:0] tens_p1 = (decimal_value_p1 / 10) % 10;
    wire [3:0] ones_p1 = decimal_value_p1 % 10;
    reg [15:0] current_color_p1;
    
    // P2 
    wire [7:0] decimal_value_p2 = sw[14:7];
    wire [3:0] hundreds_p2 = (decimal_value_p2 / 100) % 10;
    wire [3:0] tens_p2 = (decimal_value_p2 / 10) % 10;
    wire [3:0] ones_p2 = decimal_value_p2 % 10;
    reg [15:0] current_color_p2;
    
    always @(posedge my_clk_25m) begin
        if (quiz_reset) begin // QUIZ RESET IS INCORRECTLY 1
            correct_status_p1 = 0;
            correct_status_p2 = 0;
        end else begin  
            if (random_number_out == decimal_value_p1) begin
                correct_status_p1 = 1;
            end
            
            if (random_number_out == decimal_value_p2) begin
                correct_status_p2 = 1;
            end 
        end
        
        oled_color_P1 = 16'b0000000000000000;  // Black background
        oled_color_P2 = 16'b0000000000000000;  // Black background
        current_color_p1 = calculate_color(decimal_value_p1, random_number_out);
        current_color_p2 = calculate_color(decimal_value_p2, random_number_out);
        
        // P1
        if (x_p1 <= 30) begin
            oled_color_P1 = draw_digit(16, 32, hundreds_p1, x_p1, y_p1, current_color_p1);  // Leftmost digit (hundreds place)
        end else if (x_p1 >= 30 && x_p1 <= 60) begin
            oled_color_P1 = draw_digit(48, 32, tens_p1, x_p1, y_p1, current_color_p1);      // Middle digit (tens place)
        end else if (x_p1 >= 60) begin
            oled_color_P1 = draw_digit(80, 32, ones_p1, x_p1, y_p1, current_color_p1);      // Rightmost digit (ones place)
        end
        // P2
        if (x_p2 <= 30) begin
            oled_color_P2 = draw_digit(16, 32, hundreds_p2, x_p2, y_p2, current_color_p2);  // Leftmost digit (hundreds place)
        end else if (x_p2 >= 30 && x_p2 <= 60) begin
            oled_color_P2 = draw_digit(48, 32, tens_p2, x_p2, y_p2, current_color_p2);      // Middle digit (tens place)
        end else if (x_p2 >= 60) begin
            oled_color_P2 = draw_digit(80, 32, ones_p2, x_p2, y_p2, current_color_p2);      // Rightmost digit (ones place)
        end
    end
endmodule


