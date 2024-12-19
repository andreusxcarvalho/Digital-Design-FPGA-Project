`timescale 1ns / 1ps

module seven_segment_display(
    input CLOCK,                  // System clock
    input [7:0] number,           // 8-bit number to display
    output reg [3:0] an,          // Anode control for 7-segment display
    output reg [6:0] seg          // Segment control for 7-segment display
);

    reg [19:0] refresh_counter = 0;  // Refresh counter for multiplexing display
    wire refresh_clk = refresh_counter[16];  // Slower clock for multiplexing (adjusted to 16)
    reg [1:0] current_digit = 0;  // To cycle through digits
    reg [3:0] hundreds, tens, ones;

    // Increment the refresh counter
    always @(posedge CLOCK) begin
        refresh_counter <= refresh_counter + 1;
    end

    // Convert the 8-bit number to BCD digits
    always @(*) begin
        hundreds = (number / 100) % 10;
        tens = (number / 10) % 10;
        ones = number % 10;
    end

    // Multiplexing and blanking control
    always @(posedge refresh_clk) begin
        // Briefly turn off all segments for a blanking period
        an <= 4'b1111;
        seg <= 7'b1111111;  // Blank all segments briefly
        
        #1;  // Short delay for blanking period

        // Update current_digit and display corresponding digit
        current_digit <= current_digit + 1;
        
        case (current_digit)
            2'b00: begin
                an <= 4'b0111;  // Enable first digit (hundreds place)
                seg <= encode_digit(hundreds);  // Display hundreds
            end
            2'b01: begin
                an <= 4'b1011;  // Enable second digit (tens place)
                seg <= encode_digit(tens);  // Display tens
            end
            2'b10: begin
                an <= 4'b1101;  // Enable third digit (ones place)
                seg <= encode_digit(ones);  // Display ones
            end
            default: begin
                an <= 4'b1111;  // Disable all anodes by default
                seg <= 7'b1111111;  // Blank the display for unused states
            end
        endcase
    end

    // Function to encode BCD digit to 7-segment display format
    function [6:0] encode_digit;
        input [3:0] digit;
        case (digit)
            4'd0: encode_digit = 7'b1000000;  // 0
            4'd1: encode_digit = 7'b1111001;  // 1
            4'd2: encode_digit = 7'b0100100;  // 2
            4'd3: encode_digit = 7'b0110000;  // 3
            4'd4: encode_digit = 7'b0011001;  // 4
            4'd5: encode_digit = 7'b0010010;  // 5
            4'd6: encode_digit = 7'b0000010;  // 6
            4'd7: encode_digit = 7'b1111000;  // 7
            4'd8: encode_digit = 7'b0000000;  // 8
            4'd9: encode_digit = 7'b0010000;  // 9
            default: encode_digit = 7'b1111111;  // Blank if digit is invalid
        endcase
    endfunction

endmodule
