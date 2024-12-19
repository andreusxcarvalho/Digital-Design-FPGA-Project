`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2024 15:03:32
// Design Name: 
// Module Name: press_detection
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


module press_detection(
input clk,
input [31:0] count,
input pushbutton,
input [0:0] new_state,
output reg latched_press = 0,                       //latched to HIGH indefinitely after press, for functions that only need ONE press with no press count function
output reg unlatched_press = 0,                     //resets to LOW after debouncing time
output reg count_trigger_press = 0,
output reg [3:0] press_count_3bits = 3'b000,        //press_counter up to 3 bits, NO reset logic for overflow bits
output reg [1:0] press_count_2bits = 2'b00          //press_counter up to 2 bits, YES reset logic for overflow bits
);

reg allowpress = 1;                                 //initialise flag to register button press as a single press for 200ms
reg count_reset_flag = 1;                           //resets press_count to 0 if first press has not been done
reg was_in_new_state = 0;

always @ (posedge clk) 
begin
    if (new_state == 1'b1) 
    begin
        press_count_2bits <= 2'b00;                 //counts number of unlatched presses up to 2 bits
        press_count_3bits <= 3'b000;                //counts number of unlatched presses up to 3 bits
        latched_press <= 0;
        unlatched_press <= 0;
        count_trigger_press <= 0;
        allowpress <= 0;                            //Do not recognise any presses during state transition
        count_reset_flag <= 1;
        was_in_new_state <= 1;                      //Flag to identify state transition point
    end
    else begin
    if (was_in_new_state)                           // Check if we have just exited new_state
    begin
        allowpress <= 1;                            // Set allowpress to 1 after exiting new_state == 1
        was_in_new_state <= 0;                      // Clear the flag after setting allowpress
    end
    if (pushbutton == 1 && allowpress == 1) begin   //trigger counter to start counting for 200 milliseconds the moment a button press is detected and not detect any more button presses within the 200ms count                    
        count_trigger_press <= 1;                       
        allowpress <= 0;
    end
    if (count == 32'd50 && allowpress == 0) begin
        latched_press <= 1;                                                             //register the press (unlatched and latched) only after 10ms for switch debouncing    
        unlatched_press <= 1;
        if (pushbutton == 0) begin                      
            allowpress <= 1;                                                            //allow button presses after 200ms from initial button press to be recognised again if pushbutton has not been hold-pressed
            count_reset_flag <= 0;                                                      //disable press_count_2bits reset after first press
            press_count_3bits <= press_count_3bits+1;                                   //increment press_count_3bits until 3'b111
            unlatched_press <= 0;
            count_trigger_press <= 0;                                                   //reset counter when button is released
                if (press_count_2bits == 2'b11 && count_reset_flag == 0) begin
                    press_count_2bits <= 2'b01;                                         //press_count_2bits is set to 2'b01
                end
                else begin
                    press_count_2bits <= press_count_2bits+1;                           //increment press_count_2bits
                end                         
        end
        if (pushbutton == 1) begin
            allowpress <= 0;                                                            //disallow registration of button presses if pushbutton is hold-pressed
            unlatched_press <= 1;                              
        end
    end
    end
end
endmodule

