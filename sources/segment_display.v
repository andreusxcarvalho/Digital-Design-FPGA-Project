`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2024 20:57:38
// Design Name: 
// Module Name: segment_display
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


module segment_display(
input clk_1KHz,
input [3:0] state, // replace this to become the state tracker with the customisation? 
output reg [3:0] an = 4'b1111,
output reg [6:0] seg = 7'b1111111
);
    
reg [2:0] step = 3'd1; // 4 Step 7-Segment Display

always @ (posedge clk_1KHz)
begin   
    if (state == 4'b0000) 
    begin // --  display "IDLE" - 1st state only after clicking the states
    case (step)
        3'd1: 
        begin // I
            an <= 4'b0111; // Active Low
            seg <= 7'b1001111; // Active Low
            step <= step + 1; // Move to the next step                                                   
        end
        3'd2: 
        begin // D
            an <= 4'b1011; // Active Low
            seg <= 7'b1000000; // Active Low     
            step <= step + 1; // Move to the next step
        end     
        3'd3: begin // L
            an <= 4'b1101; // Active Low
            seg <= 7'b1000111; // Active Low
            step <= step + 1; // Move to the next step                                                              
        end
        3'd4: 
        begin // E
            an <= 4'b1110; // Active Low
            seg <= 7'b0000110; // Active Low
            step <= 3'd1; // Reset to start
        end
    endcase
    end

else if (state == 4'b0001) 
begin // --  display "HOLA" - 1st state only after clicking the states
    case (step)
        3'd1: begin // H
            an <= 4'b0111; // Active Low
            seg <= 7'b0001001; // Active Low
            step <= step + 1; // Move to the next step                                                   
        end
        3'd2: begin // O
            an <= 4'b1011; // Active Low
            seg <= 7'b1000000; // Active Low     
            step <= step + 1; // Move to the next step
        end     
        3'd3: begin // L
            an <= 4'b1101; // Active Low
            seg <= 7'b1000111; // Active Low
            step <= step + 1; // Move to the next step                                                              
        end
        3'd4: begin // A
            an <= 4'b1110; // Active Low
            seg <= 7'b0001000; // Active Low
            step <= 3'd1; // Reset to start
            end
    endcase  
end

else if (state == 4'b0110) // Game Over state

begin // --  display "OVER" - last state at State 6
    case (step)
        3'd1: begin // O
            an <= 4'b0111; // Active Low
            seg <= 7'b1000000; // Active Low
            step <= step + 1; // Move to the next step                                                   
        end
        3'd2: begin // V
            an <= 4'b1011; // Active Low
            seg <= 7'b1000001; // Active Low     
            step <= step + 1; // Move to the next step
        end     
        3'd3: begin // E
            an <= 4'b1101; // Active Low
            seg <= 7'b0000110; // Active Low
            step <= step + 1; // Move to the next step                                                              
        end
        3'd4: begin // r
            an <= 4'b1110; // Active Low
            seg <= 7'b0101111; // Active Low
            step <= 3'd1; // Reset to start
            end
    endcase
    end 
else
    begin
            an <= 4'b1111;        //Turns off anodes (active-low)
            seg <= 7'b1111111;    //Turns off cathodes (active-low)
            step = 3'd1;    
       
    end 
end
endmodule

