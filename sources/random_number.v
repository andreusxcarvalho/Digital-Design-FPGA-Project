`timescale 1ns / 1ps

module random_number(
    input CLOCK,                  // System clock
    input trigger,                // Trigger input (bit flip)
    output reg [7:0] random_out    // 8-bit random number output
    );
    
    reg [31:0] large_counter = 0;  // 32-bit counter for random number generation
    reg done_random = 0;           // Flag to indicate random number generation done
    reg previous_trigger = 0;      // Stores the previous state of the trigger

    always @(posedge CLOCK) begin
        // Detect either rising or falling edge of the trigger (bit flip)
        if (!done_random && (trigger != previous_trigger)) begin
            large_counter <= large_counter + 1234321;  // Increment the counter by a step
        end
        
        // If random generation is done, take the mod 256 result
        if (trigger != previous_trigger && !done_random) begin
            random_out <= (large_counter % 128 == 0) ? 8'd50 : large_counter % 128;
            done_random <= 1;                       // Set done flag to stop further increments
        end

        // Reset random number generation when the trigger flips again
        if (trigger == previous_trigger) begin
            done_random <= 0;                       // Reset done flag
        end

        // Store the previous trigger state for edge detection
        previous_trigger <= trigger;
    end
endmodule
