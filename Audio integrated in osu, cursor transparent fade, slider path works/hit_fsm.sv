`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2025 11:23:19 AM
// Design Name: 
// Module Name: hit_fsm
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

module hit_fsm #(
    parameter NUM_OBJECTS = 10,
    parameter HIT_RADIUS_SQ = 900 // 30 px radius squared
)(
    input  logic clk,
    input  logic rst,
    input  logic [31:0] game_time_ms,
    input  logic [9:0] cursor_x, cursor_y,
    input  logic button_pressed,
    input  logic [1:0] game_state,

    output logic [NUM_OBJECTS-1:0] hit_registered,
    output logic [NUM_OBJECTS-1:0] object_active,
    output logic [NUM_OBJECTS-1:0] object_spawned,
    output logic [15:0] score
);

    typedef enum logic [1:0] {
        CIRCLE,
        SLIDER,
        SPINNER
    } object_type_t;
    
    typedef struct packed {
        object_type_t object;
        int start_x; int start_y;
        int end_x; int end_y;
        int appear_time_ms;
        int hit_time_ms;
        int slider_duration_ms;
    } hit_object_t;

    hit_object_t beatmap [NUM_OBJECTS] = '{
        '{CIRCLE,  000, 000, 000, 000, 8000,  9000,  0},
        '{SLIDER,      050, 370, 300, 370, 10000, 11000, 2000},
        '{CIRCLE,  150, 400, 000, 000, 12000, 13000,  0},
        '{SLIDER,      500, 325, 575, 275, 14000, 15000, 2500},
        '{CIRCLE,  575, 275, 000, 000, 15500, 16500,  0},
        '{CIRCLE,  250, 250, 000, 000, 18000, 19000,  0},
        '{CIRCLE,  150, 150, 000, 000, 19500, 20500,  0},
        '{CIRCLE,  150, 300, 000, 000, 21000, 22000,  0},
        '{CIRCLE,  220, 280, 000, 000, 23000, 24000,  0},
        '{CIRCLE,  340, 200, 000, 000, 25000, 26000,  0}
    };

    logic [NUM_OBJECTS-1:0] object_hit;
    logic [NUM_OBJECTS-1:0] slider_active;

    // click-edge detection
    logic button_pressed_prev;
    logic button_pressed_edge;

    //sort of debounces button and sents click pulse not sustained signal
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            button_pressed_prev <= 1'b0;
            button_pressed_edge <= 1'b0;
        end else begin
            button_pressed_edge <= button_pressed && !button_pressed_prev;
            button_pressed_prev <= button_pressed;
        end
    end

    // main FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst || game_state == 2'd0) begin
            object_spawned  <= '0;
            object_active   <= '0;
            hit_registered  <= '0;
            object_hit      <= '0;
            slider_active   <= '0;
            score           <= 16'd0;
        end else begin
            // clear one-shot registers each cycle
            hit_registered <= '0;

            for (int i = 0; i < NUM_OBJECTS; i++) begin
                // spawn when time arrives
                if (!object_spawned[i] && game_time_ms >= beatmap[i].appear_time_ms) begin
                    object_active[i]  <= 1'b1;
                    object_spawned[i] <= 1'b1;
                    slider_active[i]  <= (beatmap[i].object == SLIDER);
                end


                if (beatmap[i].object == SLIDER && slider_active[i] && 
                        game_time_ms > (beatmap[i].hit_time_ms + beatmap[i].slider_duration_ms)) begin
                    slider_active[i]  <= 1'b0;
                    object_active[i]  <= 1'b0;
                    object_hit[i]     <= 1'b1;
                end else if (beatmap[i].object == CIRCLE && object_active[i] && (game_time_ms > beatmap[i].hit_time_ms + 400)) begin
                    object_active[i] <= 1'b0;
                    object_hit[i]    <= 1'b1;
                end

                // Continuous slider scoring logic
                if (beatmap[i].object == SLIDER && slider_active[i]) begin
                    logic signed [10:0] dx, dy;
                    logic [21:0] dist_sq;
            
                    // Calculate slider-ball position dynamically
                    int elapsed_time = game_time_ms - beatmap[i].hit_time_ms;
                    int slider_ball_x;
                    int slider_ball_y;
                    
                    if (elapsed_time < 0) begin
                        elapsed_time = 0;
                    end
                    if (elapsed_time > beatmap[i].slider_duration_ms) begin
                        elapsed_time = beatmap[i].slider_duration_ms;
                    end
            
                 
                    slider_ball_x = beatmap[i].start_x + ((beatmap[i].end_x - beatmap[i].start_x) * elapsed_time) / beatmap[i].slider_duration_ms;
                    
                    slider_ball_y = beatmap[i].start_y + ((beatmap[i].end_y - beatmap[i].start_y) * elapsed_time) / beatmap[i].slider_duration_ms;
            
                    dx = $signed(cursor_x + 32) - $signed(slider_ball_x + 32);
                    dy = $signed(cursor_y + 32) - $signed(slider_ball_y + 32);
                    dist_sq = dx*dx + dy*dy;
            
                    // Award points continuously if button held and cursor within hit-radius
                    if (button_pressed && (dist_sq <= HIT_RADIUS_SQ)) begin
                        if (game_time_ms[4:0] == 5'b0) begin // Score every ~32ms if conditions met
                            score <= score + 16'd10; // Smaller incremental slider score
                        end
                    end
                end
                
                // hit or early-click removal
                if (beatmap[i].object == CIRCLE && object_active[i] && !object_hit[i] && button_pressed_edge) begin
                    // signed delta for distance calc
                    logic signed [10:0] dx;
                    logic signed [10:0] dy;
                    logic        [21:0] dist_sq;
                    logic        [31:0] dt;
                    
                    int target_x = beatmap[i].start_x;
                    int target_y = beatmap[i].start_y;
                    
                    if(beatmap[i].object == SLIDER && slider_active[i]) begin
                        int elapsed_time = game_time_ms - beatmap[i].hit_time_ms;
                        if(elapsed_time < 0) elapsed_time = 0;
                        if(elapsed_time > beatmap[i].slider_duration_ms) elapsed_time = beatmap[i].slider_duration_ms;
                        
                        target_x = target_x + (beatmap[i].end_x - beatmap[i].start_x) * elapsed_time / beatmap[i].slider_duration_ms;
                        target_y = target_y + (beatmap[i].end_y - beatmap[i].start_y) * elapsed_time / beatmap[i].slider_duration_ms;
                    end

                    dx      = $signed(cursor_x + 6'd32) - $signed(target_x + 6'd32);        //calculate from center of hit circle
                    dy      = $signed(cursor_y + 6'd32) - $signed(target_y + 6'd32);            //and center of cursor sprite
                    dist_sq = dx*dx + dy*dy;
                    dt      = (game_time_ms > beatmap[i].hit_time_ms)
                                ? (game_time_ms - beatmap[i].hit_time_ms)
                                : (beatmap[i].hit_time_ms - game_time_ms);

                    if (dist_sq <= HIT_RADIUS_SQ) begin
                        // always remove the circle
                        object_active[i] <= (beatmap[i].object == SLIDER) ? slider_active[i] : 1'b0;
                        object_hit[i]    <= (beatmap[i].object != SLIDER);
                        hit_registered[i] <= 1'b1;

                        if(beatmap[i].object == SLIDER) begin
                            score <= score + 16'd10;
                        end else if (dt <= 32'd100) begin
                            score             <= score + 16'd1000;
                        end else if (dt <= 32'd200) begin
                            score             <= score + 16'd500;
                        end else if (dt <= 32'd300) begin
                            score             <= score + 16'd250;
                        end else if (dt <= 32'd400) begin
                            score             <= score + 16'd100;
                        end else if (dt <= 32'd500) begin
                            score             <= score + 16'd50;
                        end
                    end
                end
            end
        end
    end

endmodule