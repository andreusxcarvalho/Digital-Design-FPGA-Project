`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 16:47:48
// Design Name: 
// Module Name: main
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


module main(
    input basys3_clk, btnR, btnL, btnC, btnU, btnD, [15:0] sw,
    output [15:0] led,
    output [7:0] JC,                                
    output [7:0] JXADC,
    output reg [3:0] an,           
    output reg [6:0] seg
       
 );
 
 // TRACKER ____________________________________________________________
 reg [3:0] state_tracker_p1 = 4'b0000; // TODO: wE ARE STARTING FROM QN MODE
 reg [3:0] state_tracker_p2 = 4'b0000; // TODO: wE ARE STARTING FROM QN MODE
 reg [1:0] character_tracker_p1 = 2'b11; // TODO: Assume character chosen is green
 reg [1:0] character_tracker_p2 = 2'b01; // TODO: Assume character chosen is red
 reg [2:0] score_p1 = 3'b000; // TODO: wE ARE STARTING FROM QN MODE
 reg [2:0] score_p2 = 3'b000; // TODO: wE ARE STARTING FROM QN MODE
 
// CLOCKS
wire clk6p25m, clk10, clk1k, clk16, clk1, my_clk_25m;
flexible_clock clk_6p25MHz(.basys3_clock(basys3_clk), .m(32'd7), .my_clk(clk6p25m));        //6p25MHz clock
flexible_clock clk_10Hz(.basys3_clock(basys3_clk), .m(32'd4999999), .my_clk(clk10));        //10Hz clock 
flexible_clock clk_1kHz(.basys3_clock(basys3_clk), .m(32'd49999), .my_clk(clk1k));          //1KHz clock
flexible_clock clk_16Hz(.basys3_clock(basys3_clk), .m(32'd3124999), .my_clk(clk16));        //16Hz clock 
flexible_clock clk_1Hz(.basys3_clock(basys3_clk), .m(32'd49999999), .my_clk(clk1));         //1Hz clock 
flexible_clock clk_divider_25m (basys3_clk, 3'b001, my_clk_25m);  // 25MHz clock - edited to be 1 because 25MHz is for 1

// OLED OUTPUT
reg [15:0] oled_color_P1, oled_color_P2;
wire Fb_P1, sending_pixels_P1, sample_pix_P1, Fb_P2, sending_pixels_P2, sample_pix_P2; 
wire [12:0] pixel_index_P1, pixel_index_P2;
Oled_Display oled_output_P1(.reset(0), .clk(clk6p25m), .pixel_data(oled_color_P1[15:0]), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]), .frame_begin(Fb_P1), .pixel_index(pixel_index_P1[12:0]), .sending_pixels(sending_pixels_P1), .sample_pixel(sample_pix_P1));
Oled_Display oled_output_P2(.reset(0), .clk(clk6p25m), .pixel_data(oled_color_P2[15:0]), .cs(JXADC[0]), .sdin(JXADC[1]), .sclk(JXADC[3]), .d_cn(JXADC[4]), .resn(JXADC[5]), .vccen(JXADC[6]), .pmoden(JXADC[7]), .frame_begin(Fb_P2), .pixel_index(pixel_index_P2[12:0]), .sending_pixels(sending_pixels_P2), .sample_pixel(sample_pix_P2));

// Combat Modes ---------------------------------------------------------
wire player1_hit;  // Indicates when Player 1 is hit
wire player2_hit;  // Indicates when Player 2 is hit
wire [15:0]oled_color_P1_combat;
wire [15:0]oled_color_P2_combat;
wire [1:0] green_block_count_p1;
wire [1:0] green_block_count_p2;
reg reset = 0;

blink blink_leds (
    .clk10(clk10),
    .p1_dying(player1_hit),  // LED 0 blinks for Player 1 hit
    .p2_dying(player2_hit),  // LED 15 blinks for Player 2 hit
    .led(led)
);

// Round over -----------------------------------------------------------
wire [15:0] oled_color_P1_round_over;
wire [15:0] oled_color_P2_round_over;
reg [28:0] round_over_timer = 0; // 2 Seconds

roundover roundoverit (
    basys3_clk,
    my_clk_25m,
    pixel_index_P1, 
    pixel_index_P2,
    oled_color_P1_round_over,
    oled_color_P2_round_over,
    green_block_count_p1,
    green_block_count_p2
);


// QN MODE --------------------------------------------------------------
reg [2:0] number_of_rounds = 3'b001; // Tracks the number of rounds (maximum 3 rounds where end of round means hp for one of the player hits 0)
wire [3:0] an_quiz;
wire [6:0] seg_quiz;
wire [15:0] oled_color_P1_quiz;
wire [15:0] oled_color_P2_quiz;
wire correct_status_p1; // Becomes 1 if p1 is correct
wire correct_status_p2; // Becomes 1 if p2 is correct
reg round_start = 1'b0;
reg quiz_reset = 1'b0;


quiz_mode quiz (
    .basys3_clk(basys3_clk),
    .my_clk_25m(my_clk_25m),
    .my_clk_6p25m(clk6p25m),
    .quiz_reset(quiz_reset),  
    .sw(sw),
    .an(an_quiz),
    .seg(seg_quiz),
    .pixel_index_p1(pixel_index_P1),
    .pixel_index_p2(pixel_index_P2),
    .oled_color_P1(oled_color_P1_quiz),
    .oled_color_P2(oled_color_P2_quiz),
    .correct_status_p1(correct_status_p1),
    .correct_status_p2(correct_status_p2),
    .restart(round_start)
);

// Game over ------------------------------------------------------------
wire [15:0] oled_color_P1_game_over;
wire [15:0] oled_color_P2_game_over;
gameover gameoverit (
    basys3_clk,
    my_clk_25m,
    pixel_index_P1, 
    pixel_index_P2,
    oled_color_P1_game_over,
    oled_color_P2_game_over,
    score_p1,
    score_p2
);

// Tick -------------------------------------------------------------------------
wire [15:0] oled_color_P1_game_tick;
wire [15:0] oled_color_P2_game_tick;
reg [24:0] tick_p1_timer = 0; // 25 bits to count up to 25 million
reg [24:0] tick_p2_timer = 0; // 25 bits to count up to 25 million
reg [15:0] reset_counter = 0; // Counter to hold `quiz_reset` high temporarily

tick p1_tick (
    my_clk_25m,
    pixel_index_P1,
    oled_color_P1_game_tick,
    1'b0
);

tick p2_tick (
    my_clk_25m,
    pixel_index_P2,
    oled_color_P2_game_tick,
    1'b1
);

// ________________________________________________________________________________

// Main Code ______________________________________________________________________



//if state_tracker_p1 and p2 = 1 -> show pre game
//click button to enter custom char 
//only change state_tracker to two for both once both have selected char 

wire latched_press_left, unlatched_press_left;
wire latched_press_right, unlatched_press_right;
wire [3:0] an_pre_game; // Anodes for display 7-segment display IDLE and HOLA
wire [6:0] seg_pre_game; // 7-Segment Displays for IDLE amnd HOLA
wire [15:0] oled_color_start_menu_P1; // Start Menu for Player 1
wire [15:0] oled_color_start_menu_P2; // Start Menu for Player 2 
//
wire [15:0] oled_color_customisation_menu_P1; // P1 output for customisation Menu
wire [15:0] oled_color_customisation_menu_P2; // P2 output for customisation Menu

wire [1:0] character_confirm_P1; // Confirmed Player 1 - Character Customisation 
wire [1:0] character_confirm_P2; // Confirmed Player 2 - Character Customisation

always @(posedge my_clk_25m) begin
    
    if (state_tracker_p1 == 0 && state_tracker_p2 == 0) begin
    an <= an_pre_game;
    seg <= seg_pre_game;
    oled_color_P1 <= oled_color_start_menu_P1;
    oled_color_P2 <= oled_color_start_menu_P2;
    
    // Check for latched presses and update state trackers
    if (latched_press_left && latched_press_right) begin
        state_tracker_p1 <= 1; //change to mode 1 (char custom)
        state_tracker_p2 <= 1;
    end
end

    
       if (state_tracker_p1 == 1 && state_tracker_p2 == 1) begin  //char customisation
        an <= an_pre_game;
          seg <= seg_pre_game;
 oled_color_P1 <= oled_color_customisation_menu_P1;
 oled_color_P2 <= oled_color_customisation_menu_P2;

 // Check if both characters are confirmed
 if (character_confirm_P1 == 1 && character_confirm_P2 == 1) begin
     state_tracker_p1 <= 2;
     state_tracker_p2 <= 2;
     //reset regs for left and right button 
 end
end
    if (score_p1 == 1 || score_p2 == 1 || state_tracker_p1 == 6 || state_tracker_p2 == 6) begin // Game over
        an <= an_pre_game;
        seg <= seg_pre_game;
        state_tracker_p1 <= 6;
        state_tracker_p2 <= 6;
        oled_color_P1 <= oled_color_P1_game_over;
        oled_color_P2 <= oled_color_P2_game_over;
    end
    if (state_tracker_p1 == 3) begin // Tick state
        an <= an_quiz;
        seg <= seg_quiz;
        tick_p1_timer <= tick_p1_timer + 1;
        oled_color_P1 <= oled_color_P1_game_tick;
        // oled_color_P2 <= oled_color_P2_quiz;
        if (tick_p1_timer == 25_000_000) begin
            tick_p1_timer <= 0;
            state_tracker_p1 <= 4;
        end
    end 
    if (state_tracker_p2 == 3) begin  // Tick state
        an <= an_quiz;
        seg <= seg_quiz;
        tick_p2_timer <= tick_p2_timer + 1;
        oled_color_P2 <= oled_color_P2_game_tick;
        // oled_color_P1 <= oled_color_P1_quiz;
        if (tick_p2_timer == 25_000_000) begin
            tick_p2_timer <= 0;
            state_tracker_p2 <= 4;
        end
    end
    if (state_tracker_p1 == 5 && state_tracker_p2 == 5) begin // Round Over
                round_over_timer <= round_over_timer + 1;
                oled_color_P1 <= oled_color_P1_round_over;
                oled_color_P2 <= oled_color_P2_round_over;
                if (round_over_timer == 70_000_000) begin 
                    round_start <= ~round_start; // TRIGGER A NEW RANDOM NUMBER
                    round_over_timer <= 0;
                    quiz_reset = 1'b1; // Set reset pulse high for one clock cycle
                    state_tracker_p1 <= 2;
                    state_tracker_p2 <= 2;
                  
                end else begin
                    quiz_reset <= 0; // Immediately return reset to 0 after one cycle
                end
    end
    else if (state_tracker_p1 == 2 && state_tracker_p2 == 2) begin
         // Both are quiz
        quiz_reset <= 0;
        oled_color_P1 <= oled_color_P1_quiz;
        oled_color_P2 <= oled_color_P2_quiz;
        an <= an_quiz;
        seg <= seg_quiz;
        if (correct_status_p1) begin // PROBLEM: MAKE THIS SHIT 00000
            state_tracker_p1 <= 3;
        end
        if (correct_status_p2) begin // PROBLEM: MAKE THIS SHIT 00000
            state_tracker_p2 <= 3;
        end 
    end 
    else if (state_tracker_p1 == 2 && state_tracker_p2 == 4) begin // p1 is quiz, p2 is comabt
        quiz_reset <= 0;
        an <= an_quiz;
        seg <= seg_quiz;
        oled_color_P1 <= oled_color_P1_quiz;
        // TATOO: state 4
        oled_color_P2 <= oled_color_P2_combat;
        if (correct_status_p1) begin
            state_tracker_p1 <= 3;
        end
    end
    else if (state_tracker_p1 == 4 && state_tracker_p2 == 2) begin // p1 is comabt, p2 is quiz
        quiz_reset <= 0;
        an <= an_quiz;
        seg <= seg_quiz;
        oled_color_P2 <= oled_color_P2_quiz;
        // TATOO: state 4
        oled_color_P1 <= oled_color_P1_combat;
        if (correct_status_p2) begin
            state_tracker_p2 <= 3;
        end
    end
    else if (state_tracker_p1 == 4 && state_tracker_p2 == 4) begin // p1 is comabt, p2 is comabt
        quiz_reset <= 0;
        an <= 4'b1111;
        seg <= 7'b1111111;
        // TATOO: state 4
        oled_color_P1 <= oled_color_P1_combat;
        oled_color_P2 <= oled_color_P2_combat;
    end 
    else if (state_tracker_p1 == 4 && state_tracker_p2 == 3) begin
        oled_color_P1 <= oled_color_P1_combat;
    end 
    else if (state_tracker_p1 ==3 && state_tracker_p2 == 4) begin
        oled_color_P2 <= oled_color_P2_combat;
    end
    // Experimentation ---------------------------------------------------------------------------
    if (state_tracker_p1 == 4  || state_tracker_p2 == 4) begin
        if (green_block_count_p1 == 0) begin
            score_p2 <= score_p2 + 1;
            state_tracker_p1 <= 5;
            state_tracker_p2 <= 5;
        end
        if (green_block_count_p2 == 0) begin
            score_p1 <= score_p1 + 1;
            state_tracker_p1 <= 5;
            state_tracker_p2 <= 5;
        end
    end
end




// COMBAT GUI -------------------------------------------------------------------------


wire [5:0] y_P1, y_P2;
wire [6:0] x_P1, x_P2;
//wire [15:0] oled_color_P1, oled_color_P2;
//wire clk6p25m, clk10, clk1k;
//wire [12:0] pixel_index_P1, pixel_index_P2;
//wire Fb_P1, sending_pixels_P1, sample_pix_P1, Fb_P2, sending_pixels_P2, sample_pix_P2; 
wire [2:0] press_count_3bits_right;
wire [31:0] count_right_press;
wire [1:0] press_count_2bits_right;
wire count_trigger_right_press;


wire [2:0] press_count_3bits_left;
wire [31:0] count_left_press;
wire [1:0] press_count_2bits_left;
wire count_trigger_left_press;


wire [2:0] press_count_3bits_centre;
wire [31:0] count_centre_press;
wire [1:0] press_count_2bits_centre;
wire count_trigger_centre_press;
wire latched_press_centre, unlatched_press_centre;

wire [2:0] press_count_3bits_up;
wire [31:0] count_up_press;
wire [1:0] press_count_2bits_up;
wire count_trigger_up_press;
wire latched_press_up, unlatched_press_up;

wire [2:0] press_count_3bits_down;
wire [31:0] count_down_press;
wire [1:0] press_count_2bits_down;
wire count_trigger_down_press;
wire latched_press_down, unlatched_press_down;

// Wires for Player 1
wire [5:0] player1_bullet_y;      // Player 1's bullet vertical position
wire [1:0] player1_lane;          // Player 1's current lane
wire [5:0] player2_bullet_y_for_p1; // Player 2's bullet position for Player 1's reference
wire [1:0] player2_lane_for_p1;   // Player 2's lane for Player 1's reference

// Wires for Player 2
wire [5:0] player2_bullet_y;      // Player 2's bullet vertical position
wire [1:0] player2_lane;          // Player 2's current lane
wire [5:0] player1_bullet_y_for_p2; // Player 1's bullet position for Player 2's reference
wire [1:0] player1_lane_for_p2;   // Player 1's lane for Player 2's reference

// For sprite movement animation
wire count_trigger_right_press_2s;
wire [31:0] count_right_press_2s;
wire [1:0] press_count_2s_2bits_right;
wire count_trigger_left_press_2s;
wire [31:0] count_left_press_2s;
wire [1:0] press_count_2s_2bits_left;


assign x_P1 [6:0] = pixel_index_P1 % 96; //takes the remainder of the number x-axis coordinates
assign y_P1 [5:0] = pixel_index_P1/96; //takes the quotient of the number to derive y-axis coordinates
assign x_P2 [6:0] = pixel_index_P2%96; //takes the remainder of the number x-axis coordinates
assign y_P2 [5:0] = pixel_index_P2/96; //takes the quotient of the number to derive y-axis coordinates

smart_counter_50m debouncing_count_50ms_right(.clk_1KHz(clk1k), .count_trigger(count_trigger_right_press), .count(count_right_press));
smart_counter_50m debouncing_count_50ms_left(.clk_1KHz(clk1k), .count_trigger(count_trigger_left_press), .count(count_left_press));
smart_counter_50m debouncing_count_50ms_centre(.clk_1KHz(clk1k), .count_trigger(count_trigger_centre_press), .count(count_centre_press));
smart_counter_50m debouncing_count_50ms_up(.clk_1KHz(clk1k), .count_trigger(count_trigger_up_press), .count(count_up_press));
smart_counter_50m debouncing_count_50ms_down(.clk_1KHz(clk1k), .count_trigger(count_trigger_down_press), .count(count_down_press));

press_detection detect_press_right(.clk(basys3_clk), .count(count_right_press), .pushbutton(btnR), .count_trigger_press(count_trigger_right_press), .press_count_3bits(press_count_3bits_right[2:0]), .latched_press(latched_press_right), .unlatched_press(unlatched_press_right), .press_count_2bits(press_count_2bits_right[1:0]), .new_state(quiz_reset));
press_detection detect_press_left(.clk(basys3_clk), .count(count_left_press), .pushbutton(btnL), .count_trigger_press(count_trigger_left_press), .press_count_3bits(press_count_3bits_left[2:0]), .latched_press(latched_press_left), .unlatched_press(unlatched_press_left), .press_count_2bits(press_count_2bits_left[1:0]), .new_state(quiz_reset));
press_detection detect_press_centre(.clk(basys3_clk), .count(count_centre_press), .pushbutton(btnC), .count_trigger_press(count_trigger_centre_press), .press_count_3bits(press_count_3bits_centre[2:0]), .latched_press(latched_press_centre), .unlatched_press(unlatched_press_centre), .press_count_2bits(press_count_2bits_centre[1:0]), .new_state(quiz_reset));
press_detection  detect_press_up(.clk(basys3_clk), .count(count_up_press), .pushbutton(btnU), .count_trigger_press(count_trigger_up_press), .press_count_3bits(press_count_3bits_up[2:0]), .latched_press(latched_press_up), .unlatched_press(unlatched_press_up), .press_count_2bits(press_count_2bits_up[1:0]), .new_state(quiz_reset));
press_detection  detect_press_down(.clk(basys3_clk), .count(count_down_press), .pushbutton(btnD), .count_trigger_press(count_trigger_down_press), .press_count_3bits(press_count_3bits_down[2:0]), .latched_press(latched_press_down), .unlatched_press(unlatched_press_down), .press_count_2bits(press_count_2bits_down[1:0]), .new_state(quiz_reset));

smart_counter_2s counter_2s_right(.clk_1Hz(clk1), .count_trigger(count_trigger_right_press_2s), .count(count_right_press_2s));  //counter that HOLDS it value of 2s after counting from 0 to 2 (NO auto-reset when 2s is reached)
smart_counter_2s counter_2s_left(.clk_1Hz(clk1), .count_trigger(count_trigger_left_press_2s), .count(count_left_press_2s));

press_detection_2s  detect_press_2s_right(.clk(basys3_clk), .count(count_right_press_2s), .pushbutton(btnR), .count_trigger_press(count_trigger_right_press_2s), .press_count_2bits(press_count_2s_2bits_right[1:0]), .new_state(0)); //button detection that recognises button presses after after 2 secs
press_detection_2s  detect_press_2s_left(.clk(basys3_clk), .count(count_left_press_2s), .pushbutton(btnL), .count_trigger_press(count_trigger_left_press_2s), .press_count_2bits(press_count_2s_2bits_left[1:0]), .new_state(0));

wire [1:0] selected_character_P1; // Player 1 Selection
wire [1:0] selected_character_P2; // Player 2 Selection

combat_gui combat_gui_P1 (
    .quiz_reset(quiz_reset),
    .SW(sw[15:0]),
    .press_count_selection(press_count_2s_2bits_right[1:0]),
    .clk(basys3_clk),
    .clk_10(clk10),
    .clk_16(clk16), //added for movement animation
    .index(pixel_index_P1[12:0]),
    .selected_character(selected_character_P1),                 //to update to wire during integration
    .oled_color(oled_color_P1_combat[15:0]),
    .fire_bullet(unlatched_press_up),          // Using the up button to fire the bullet
    .flip_image(0),
    .opponent_bullet_y(player2_bullet_y),      // Player 2's bullet info for Player 1's damage monitor
    .opponent_bullet_lane(player2_lane),
    .bullet_y(player1_bullet_y),               // Player 1's bullet position
    .player_lane(player1_lane),
    .player_hit(player1_hit),
    .green_block_count(green_block_count_p1)  
                  // Player 1's lane
);

combat_gui combat_gui_P2 (
    .quiz_reset(quiz_reset),
    .SW(sw[15:0]),
    .press_count_selection(press_count_2s_2bits_left[1:0]),
    .clk(basys3_clk),
    .clk_10(clk10),
    .clk_16(clk16), //added for movement animation
    .index(pixel_index_P2[12:0]),
    .selected_character(selected_character_P2),             //to update to wire during integration
    .oled_color(oled_color_P2_combat[15:0]),
    .fire_bullet(unlatched_press_down), 
    .flip_image(1),
    .opponent_bullet_y(player1_bullet_y),      // Player 1's bullet info for Player 2's damage monitor
    .opponent_bullet_lane(player1_lane),
    .bullet_y(player2_bullet_y),               // Player 2's bullet position
    .player_lane(player2_lane),
    .player_hit(player2_hit),                // Player 2's lane
    .green_block_count(green_block_count_p2)
);

// PRE-GAME-MODULES -------------------------------------------------------------------------
// Pre- Game Displays Module 


wire [3:0] state; // FSM -- May need to remove to integrate together Declaration of state -- this is used for the 7-segment display - need to integrate together with the 7-segment at the start menu together
wire [31:0] run_state; // FSM -- May need to remove to integrate inside together -- Running of state -- this is the declaration
// How to clear for the X component and the Y Component for P1 and P2 ? Needed to ask Ojas for this one before we can continue for the Character Customisation Menu
// May need to clear for the run state and the original state


// Need to adjust this one for State , remove X, Y state, remove the run_state to prevent for any multi-driven net error.
     segment_display segment_display(.clk_1KHz(clk1k), .state(state_tracker_p1), .an(an_pre_game[3:0]), .seg(seg_pre_game[6:0]));
     start_menu start_menu_P1(.index(pixel_index_P1[12:0]), .clk(basys3_clk), .clk_10(clk10),.press_count(press_count_2bits_right[1:0]), .oled_color(oled_color_start_menu_P1[15:0]), .flip_image(0));
     start_menu start_menu_P2(.index(pixel_index_P2[12:0]), .clk(basys3_clk), .clk_10(clk10),.press_count(press_count_2bits_left[1:0]), .oled_color(oled_color_start_menu_P2[15:0]), .flip_image(1));
     character_customisation_gui customisation_menu_P1(.index(pixel_index_P1[12:0]), .clk(basys3_clk), .clk_25m( my_clk_25m), .clk_10(clk10), .oled_color(oled_color_customisation_menu_P1[15:0]), .press_count_selection(press_count_2bits_right[1:0]),.press_confirm(unlatched_press_up), .selected_character(selected_character_P1[1:0]), .character_confirm(character_confirm_P1), .flip_image(0));  //changed to latched
     character_customisation_gui customisation_menu_P2(.index(pixel_index_P2[12:0]), .clk(basys3_clk), .clk_25m( my_clk_25m), .clk_10(clk10), .oled_color(oled_color_customisation_menu_P2[15:0]), .press_count_selection(press_count_2bits_left[1:0]),.press_confirm(unlatched_press_down), .selected_character(selected_character_P2[1:0]), .character_confirm(character_confirm_P2), .flip_image(1)); //changed to latched

endmodule
