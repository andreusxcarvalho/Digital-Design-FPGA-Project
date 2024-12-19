`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2024 03:42:41
// Design Name: 
// Module Name: press_detection_2s
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

module press_detection_2s(
    input clk,
    input pushbutton,
    input [0:0] new_state,
    output reg count_trigger_press = 1,            // Start counter intially
    output reg [1:0] press_count_2bits = 2'b00,    // Press counter up to 2 bits
    input [31:0] count                             // Count in seconds from smart_counter_2s
);

reg allowpress = 1;                            // Flag to register button press
reg was_in_new_state = 0;
reg count_reset_flag = 1;      

always @ (posedge clk) 
begin
    if (new_state == 1'b1) 
    begin
        // Reset press count on state transition
        press_count_2bits <= 2'b00;            
        count_trigger_press <= 1;
        allowpress <= 0;                         // Do not recognize any presses during state transition
        was_in_new_state <= 1;                   //Flag to identify state transition point
        count_reset_flag <= 1;
    end 
    else 
    begin
        if (was_in_new_state)                           // Check if we have just exited new_state
        begin
            allowpress <= 1;                            // Set allowpress to 1 after exiting new_state == 1
            was_in_new_state <= 0;                      // Clear the flag after setting allowpress
        end
        // Button press logic
        if (pushbutton == 1 && allowpress == 1 && count == 32'd3) 
        begin
        allowpress <= 0;                            // Disallow subsequent presses immediately
        count_trigger_press <= 0;
        end
        if (count == 32'd0 && allowpress == 0) 
        begin
            if (pushbutton == 0) 
            begin
                allowpress <= 1;
                count_reset_flag <= 0;          //disable press_count_2bits reset after first press
                count_trigger_press <= 1;       // Indicate a valid press count trigger
                allowpress <= 1;                // Allow presses after 2 seconds
                    if (press_count_2bits == 2'b11 && count_reset_flag == 0) 
                    begin
                        press_count_2bits <= 2'b01;                                         //press_count_2bits is set to 2'b01
                    end
                    else 
                    begin
                        press_count_2bits <= press_count_2bits+1;                       //increment press_count_2bits
                    end               
            end
            if (pushbutton == 1) 
            begin
                allowpress <= 0;                                 
            end
        end
    end
end
endmodule
