`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 04/18/2025 09:31:21 AM
// Design Name: 
// Module Name: osu_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: top level file for the overall final project
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module osu_top (
    input  logic Clk, //100_MHz
    input  logic reset_rtl_0,
    
    input  logic start_btn,

    // HDMI TMDS outputs
    output logic       hdmi_tmds_clk_p,
    output logic       hdmi_tmds_clk_n,
    output logic [2:0] hdmi_tmds_data_p,
    output logic [2:0] hdmi_tmds_data_n,
    
    //USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,
    
    //UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,
    
    //HEX Display
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB,
    
    //Audio signals
    output logic AUDIO_PWM,
    output logic CS_BO,
    output logic SCLK_O,
    output logic MOSI_O,
    input  logic MISO_I
);

    // VGA controller outputs
    logic [9:0] drawX;
    logic [8:0] drawY;
    logic active;
    logic hsync, vsync;

    //used to delay write (x,y) coords
    logic [9:0] tempx;
    logic [8:0] tempy;
    
    //coords and palette index to write into framebuffer bram
    logic [9:0] write_x;
    logic [8:0] write_y;
    logic [3:0] write_index;
    
    // Framebuffer output
    logic [23:0] pixel_color;
    logic [7:0] red, green, blue;
    assign red   = pixel_color[23:16];
    assign green = pixel_color[15:8];
    assign blue  = pixel_color[7:0];
    logic [3:0] pixel_index;
    logic [23:0] temp_color;
    logic bgd_en, cursor_en;
    logic [3:0] background_pixel;
    logic [3:0] sprite_pixel;
    logic [3:0] cursor_pixel;
    logic score_pixel, high_score_pixel;
    logic sprite_on, cursor_on, approach_on, score_on, high_score_on;
    logic [7:0] approach_fade_color;
    
    //Mouse Tracking signals
    logic [9:0] CursorX, CursorY;
    logic button_clicked;
    
    //Game timer and hit objects
    parameter NUM_OBJECTS = 10;
    logic [NUM_OBJECTS-1:0] object_active;
    logic [NUM_OBJECTS-1:0] hit_registered;
    logic [NUM_OBJECTS-1:0] object_spawned;
    logic [31:0] game_time_ms;
    logic [9:0] active_sprite_x;
    logic [8:0] active_sprite_y;
    logic object_found;
    
    
    //Scoring variables
    logic [15:0] score;   //actual score (in binary)
    logic [3:0] calcScore[4];  //hex seg signals (score in base 10)
    
    //Audio variables
    logic enable_audio;
    assign enable_audio = (game_state == 2'd1);
    logic reset_audio;
    assign reset_audio = (game_state == 2'd0);
    
    
////////////////////////////////////////////////////////////////////////
    // CLOCK SIGNALS AND INSTANTIATION
////////////////////////////////////////////////////////////// /////////  
    logic clk_25mhz_unlocked, clk_25mhz;
    logic clk_125mhz_unlocked, clk_125mhz;
    logic clk_100mhz_unlocked, clk_100mhz;
    logic clk_locked;
    
    // Instantiate Clocking Wizard
    clk_wiz_0 pixel_clkgen (
        .clk_out1(clk_25mhz_unlocked),  // 25 MHz output
        .clk_out2(clk_125mhz_unlocked),  // 125 MHz output
        .clk_out3(clk_100mhz_unlocked),
        .reset(reset_rtl_0),
        .locked(clk_locked),
        .clk_in1(Clk)
    );
    //gating the clock signals on the locked signal
    assign clk_25mhz = clk_locked ? clk_25mhz_unlocked : 1'b0;
    assign clk_125mhz = clk_locked ? clk_125mhz_unlocked : 1'b0;
    assign clk_100mhz = clk_locked ? clk_100mhz_unlocked : 1'b0;
//////////////////////////////////////////////////////////////////////
    //Overall Game FSM 
    
    //Menu  -> wait for button click to start
    //Gameplay   -> assert DONE signal when game is over
    //End   -> wait for button to go back to main menu
    
    logic game_start;
    logic mouse_click_debounced_synced;
    logic [1:0] game_state;
    
    game_fsm game_fsm (
      .clk       (clk_100mhz),
      .rst_n     (~reset_rtl_0),
      .start_btn (mouse_click_debounced_synced),  //mapped to mouse click for now
      .play_done (fsm_play_done),
      .state     (game_state)
    );
    
    assign game_start = (game_state == 2'd1);
    
    debounce_sync click_clean (
      .clk         (clk_100mhz),
      .rst_n       (~reset_rtl_0),
      .click_in    (button_clicked),
      .click_pulse (mouse_click_debounced_synced)
    );
    
    hex_driver hex_driverB (
        .clk(clk_100mhz),
        .reset(reset_rtl_0),
        .in({4'h0, 4'h0, 4'h0, {2'd0, game_state}}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );
    
    logic raw_done;
    assign raw_done = (&object_spawned) && (object_active == '0);

    // fsm_play_done: only pulses once per play, clears on menu
    logic fsm_play_done;
    always_ff @(posedge clk_100mhz or posedge reset_rtl_0) begin
      if (reset_rtl_0) begin
        fsm_play_done <= 1'b0;
      end
      else if (game_state == 2'd0) begin
        // entering MENU: clear the done flag
        fsm_play_done <= 1'b0;
      end
      else if (raw_done) begin
        // once the objects are all done, set it
        fsm_play_done <= 1'b1;
      end
      // otherwise hold its previous value
    end
 
//////////////////////////////////////////////////////////////////
    //Game Clock and Hit FSM Instantiation
//////////////////////////////////////////////////////////////////

    game_timer game_clock (
        .clk(clk_100mhz),
        .rst(reset_rtl_0 || game_state == 2'd0),
        .start(game_start),
        .game_time_ms(game_time_ms)
    );

    hit_fsm #(.NUM_OBJECTS(NUM_OBJECTS)) hit_fsm_inst (
        .clk(clk_100mhz),
        .rst(reset_rtl_0),
        .game_time_ms(game_time_ms),
        .cursor_x(CursorX),
        .cursor_y(CursorY),
        .button_pressed(button_clicked),
        .game_state(game_state),
        .hit_registered(hit_registered),
        .object_active(object_active),
        .object_spawned(object_spawned),
        .score(score)
    );
    
///////////////////////////////////////////////////////////////
    //Scoring and display on Hex Segs
///////////////////////////////////////////////////////////////
    hex_driver hex_driverA (
        .clk(clk_100mhz),
        .reset(reset_rtl_0),
        .in(calcScore),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );

    scoreConvert curScoreConvert (
        .binary_in(score),
        .bcd(calcScore)
    );
    
    logic [3:0] highScoreBCD [4];
    scoreConvert maxScoreConvert (
        .binary_in(high_score),
        .bcd(highScoreBCD)
    );
    
    
    logic [1:0] prev_game_state;
    always_ff @(posedge clk_100mhz or posedge reset_rtl_0) begin
        if(reset_rtl_0) begin
            prev_game_state <= 2'd0;
        end else begin
            prev_game_state <= game_state;
        end
    end
    
    logic [15:0] high_score;
    always_ff @(posedge clk_100mhz or posedge reset_rtl_0) begin
        if(reset_rtl_0) begin
            high_score <= 16'd0;
        end else if (prev_game_state == 2'd1 && game_state == 2'd2) begin
            if (score > high_score) begin
                high_score <= score;
            end
        end
    end
//////////////////////////////////////////////////////////////

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
    
    logic [$clog2(NUM_OBJECTS)-1:0] active_object_index;
    

    always_comb begin
        active_sprite_x = 10'd0;
        active_sprite_y = 9'd0;
        active_object_index = '0;
        object_found = 1'b0;
    
        for (int i = 0; i < NUM_OBJECTS; i++) begin
            if (object_active[i] && !object_found) begin
                active_object_index = i;
                object_found = 1'b1;
    
                if (beatmap[i].object == SLIDER) begin
                    int sx, sy, ex, ey, duration, et;
                    sx = beatmap[i].start_x;
                    sy = beatmap[i].start_y;
                    ex = beatmap[i].end_x;
                    ey = beatmap[i].end_y;
                    duration = beatmap[i].slider_duration_ms;
                    et = game_time_ms - beatmap[i].hit_time_ms;
                    if (et < 0) et = 0;
                    if (et > duration) et = duration;
    
                    active_sprite_x = sx + ((ex - sx) * et) / duration;
                    active_sprite_y = sy + ((ey - sy) * et) / duration;
                end else begin
                    active_sprite_x = beatmap[i].start_x;
                    active_sprite_y = beatmap[i].start_y;
                end
            end
        end
    end
    
/////////////////////////////////////////////////////////////////
    //Trying to implement fading cursor trail
    
    parameter CURSOR_TRAIL_LEN = 32; // number of trail dots
    typedef struct packed {
        logic [9:0] x;
        logic [8:0] y;
    } point_t;
    
    point_t cursor_trail [CURSOR_TRAIL_LEN];
    logic [$clog2(CURSOR_TRAIL_LEN)-1:0] cursor_index;
    
//    logic [1:0] trail_timer;
    always_ff @(posedge vsync or posedge reset_rtl_0) begin
        if (reset_rtl_0) begin
            cursor_index <= 0;
//            trail_timer <= 0;
        end else begin
//            trail_timer <= trail_timer + 1;
            cursor_trail[cursor_index] <= '{x: CursorX + 6'd32, y: CursorY + 6'd32};
            cursor_index <= cursor_index + 1;
    
//            if (trail_timer == 0) begin // update ~every 4 frames
//                cursor_trail[cursor_index] <= '{x: CursorX + 6'd32, y: CursorY + 6'd32};
//                cursor_index <= cursor_index + 1;
//            end
        end
    end
    
    logic [CURSOR_TRAIL_LEN-1:0] trail_on;
    logic [7:0] trail_alpha [CURSOR_TRAIL_LEN-1:0];

    always_comb begin
    for (int i = 0; i < CURSOR_TRAIL_LEN; i++) begin
        // Convert logical age (0 = newest, N = oldest) into physical index
        int index = (cursor_index - i - 1 + CURSOR_TRAIL_LEN) % CURSOR_TRAIL_LEN;

        logic signed [10:0] dx = $signed(drawX) - $signed(cursor_trail[index].x);
        logic signed [10:0] dy = $signed(drawY) - $signed(cursor_trail[index].y);
        logic [21:0] dist_sq = dx*dx + dy*dy;

        trail_on[i] = (dist_sq <= 64); // 8px radius
        trail_alpha[i] = 255 - (i * (255 / CURSOR_TRAIL_LEN)); // Newest = 255, oldest = ~0
    end
end
    
    logic trail_hit;
    logic [7:0] trail_intensity;
    always_comb begin
        trail_hit = 0;
        trail_intensity = 0;
    
        for (int i = 0; i < CURSOR_TRAIL_LEN; i++) begin
            if (trail_on[i] && trail_alpha[i] > trail_intensity) begin
                trail_hit = 1;
                trail_intensity = trail_alpha[i];
            end
        end
    end
    
//////////////////////////////////////////////////////////////////  
   //Background and Sprite and Cursor Controllers
   //MUX selects which to write into memory for given (x,y) coord 
////////////////////////////////////////////////////////////////// 
    
    sprite_controller sp_cntl(
        .clk(clk_25mhz),
        .hcount(drawX),
        .vcount(drawY),
        .sprite_x(active_sprite_x),
        .sprite_y(active_sprite_y),
        .sprite_pixel(sprite_pixel),
        .sprite_on(sprite_on)
    );
    
    cursor_controller cs_cntl(
        .clk(clk_25mhz),
        .hcount(drawX),
        .vcount(drawY),
        .sprite_x(CursorX),
        .sprite_y(CursorY),
        .sprite_pixel(cursor_pixel),
        .sprite_on(cursor_on)
    );
    
    background_controller bgd_cntl(
        .clk(clk_25mhz),
        .hcount(drawX),
        .vcount(drawY),
        .background_pixel(background_pixel)
    );
    
    approach_circle_controller #(
        .MAX_RADIUS(80),       // tune to your circle size
        .DURATION_MS(1200)     // how long before hit-time it shrinks
    ) approach_ctrl (
        .clk           (clk_25mhz),       // use your pixel clock
        .rst           (reset_rtl_0),
        .game_time_ms  (game_time_ms),
        .object_active (object_found),    // true when an object is up
        .circle_x      (active_sprite_x + 6'd32),       //center on hit-circle
        .circle_y      (active_sprite_y + 6'd32),
        .drawX         (drawX),
        .drawY         (drawY),
        .approach_on   (approach_on),
        .approach_fade_color(approach_fade_color)
    );
    
    logic slider_path_on;

    slider_path_controller slider_path_ctrl (
        .clk(clk_25mhz),
        .drawX(drawX),
        .drawY(drawY),
        .start_x(beatmap[active_object_index].start_x + 6'd32),
        .start_y(beatmap[active_object_index].start_y + 6'd32),
        .end_x(beatmap[active_object_index].end_x + 6'd32),
        .end_y(beatmap[active_object_index].end_y + 6'd32),
        .enable(object_found && beatmap[active_object_index].object == SLIDER),
        .path_on(slider_path_on)
    );
    
    score_box #(
      .BOX_X0(520), 
      .BOX_Y0(5),
      .DIGIT_W(8), 
      .DIGIT_H(16), 
      .N_DIGITS(4)
    ) sc_ctrl (
      .drawX      (drawX),
      .drawY      (drawY),
      .bcd_digits (calcScore),    // your 4-digit BCD array
      .score_on   (score_on),
      .score_bit  (score_bit)
    );
    
    score_box #(
      .BOX_X0(562), 
      .BOX_Y0(5),
      .DIGIT_W(8), 
      .DIGIT_H(16), 
      .N_DIGITS(4)
    ) high_sc_ctrl (
      .drawX      (drawX),
      .drawY      (drawY),
      .bcd_digits (highScoreBCD),    // your 4-digit BCD array
      .score_on   (high_score_on),
      .score_bit  (high_score_bit)
    );
    
    palette pal (
        .index(pixel_index),
        .bgd_en(bgd_en),
        .color(temp_color)
    );
    
    always_comb begin
        if (high_score_on) begin
            if(high_score_bit) begin
                pixel_color = 24'hFFD700;
            end else begin
                pixel_color = 24'h000000;
            end
        end else if (score_on) begin
            if(score_bit) begin
                pixel_color = 24'hFFFFFF;
            end else begin
                pixel_color = 24'h000000;
            end
        end else if (cursor_on) begin
            pixel_color = 24'hFFFFFF;
        end else if (trail_hit) begin  //pixel_color = {trail_intensity, trail_intensity, trail_intensity};
            pixel_color[23:16] = (8'hFF * trail_intensity + temp_color[23:16] * (255 - trail_intensity)) >> 8;
            pixel_color[15:8] = (8'hFF * trail_intensity + temp_color[15:8] * (255 - trail_intensity)) >> 8;
            pixel_color[7:0] = (8'hFF * trail_intensity + temp_color[7:0] * (255 - trail_intensity)) >> 8;
        end else if (slider_path_on) begin
            pixel_color = 24'hBBBBBB;
        end else if (approach_on) begin
            pixel_color = {3{approach_fade_color}};
        end else begin
            pixel_color = temp_color;
        end
    end
    
    always_comb begin
        if(sprite_on && object_found) begin
            pixel_index = sprite_pixel;
            bgd_en = 1'b0;
        end else begin
            pixel_index = background_pixel;
            bgd_en = 1'b1;
        end
    end

//////////////////////////////////////////////////////////////////
    //Display stuff
/////////////////////////////////////////////////////////////////
    
    // VGA timing 
    vga_controller vga_ctrl (
        .pixel_clk(clk_25mhz),
        .reset(reset_rtl_0),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(active),
        .sync(),               // not used
        .drawX(drawX),
        .drawY(drawY)
    );
    
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25mhz),
        .pix_clkx5(clk_125mhz),
        .pix_clk_locked(clk_locked),
        //Reset is active LOW
        .rst(reset_rtl_0),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(active),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p),          
        .TMDS_CLK_N(hdmi_tmds_clk_n),          
        .TMDS_DATA_P(hdmi_tmds_data_p),         
        .TMDS_DATA_N(hdmi_tmds_data_n)          
    );
    
////////////////////////////////////////////////////////////
    //mb_block used for mouse tracking now
////////////////////////////////////////////////////////////

    mb_block_wrapper mb (
        .Clk(clk_100mhz),
        .reset_rtl_0(reset_rtl_0),
        .vsync(vsync),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .CursorX(CursorX),
        .CursorY(CursorY),
        .button_clicked(button_clicked)
    );
    
////////////////////////////////////////////////////////////
    //Audio
////////////////////////////////////////////////////////////

    audio_top audio_ctrl (
        .Clk(clk_100mhz),
        .reset_rtl_0(reset_rtl_0),
        .enable_audio(enable_audio),
        .reset_audio(reset_audio),
        .AUDIO_PWM(AUDIO_PWM),
        .CS_BO(CS_BO),
        .MISO_I(MISO_I),
        .MOSI_O(MOSI_O),
        .SCLK_O(SCLK_O)
    );
    

endmodule