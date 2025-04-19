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
    input  logic Clk,
    input  logic reset_rtl_0,

    // HDMI TMDS outputs (used by DAC, no logic needed here)
    output logic       hdmi_tmds_clk_p,
    output logic       hdmi_tmds_clk_n,
    output logic [2:0] hdmi_tmds_data_p,
    output logic [2:0] hdmi_tmds_data_n
);

    // VGA controller outputs
    logic [9:0] drawX;
    logic [8:0] drawY;
    logic active;
    logic hsync, vsync;

    // Framebuffer output
    logic [11:0] pixel_color;

    // Test pattern writer
    logic we, done;
    logic [9:0] write_x;
    logic [8:0] write_y;
    logic [3:0] write_index;
    
    logic clk_25mhz_raw;
    logic clk_25mhz;
    logic clk_125mhz_raw;
    logic clk_125mhz;
    logic clk_locked;
    
    // Instantiate Clocking Wizard
    clk_wiz_0 pixel_clkgen (
        .clk_out1(clk_25mhz_raw),  // 25 MHz output
        .clk_out2(clk_125mhz_raw),  // 125 MHz output
        .reset(reset_rtl_0),
        .locked(clk_locked),
        .clk_in1(Clk)
    );
    //gating the clock signals on the locked signal
    assign clk_25mhz = clk_locked ? clk_25mhz_raw : 1'b0;
    assign clk_125mhz = clk_locked ? clk_125mhz_raw : 1'b0;

    // Test pattern writer (fills screen at startup)
//    test_pattern_writer tp (
//        .clk(clk_25mhz),
//        .rst(reset_rtl_0),
//        .we(we),
//        .write_x(write_x),
//        .write_y(write_y),
//        .write_index(write_index)
//    );

    logic [9:0] tempx;
    logic [8:0] tempy;
    logic [9:0] hcount;
    logic [8:0] vcount;
    always_ff @(posedge clk_25mhz) begin
        tempx <= drawX;
        tempy <= drawY;
    end
    always_ff @(posedge clk_25mhz) begin
        hcount <= tempx;
        vcount <= tempy;
    end

    logic [3:0] background_pixel;
    logic [3:0] sprite_pixel;
    logic sprite_on;
    
    sprite_controller (
        .clk(clk_25mhz),
        .hcount(hcount),
        .vcount(vcount),
        .sprite_x(10'd140),
        .sprite_y(9'd140),
        .sprite_pixel(sprite_pixel),
        .sprite_on(sprite_on)
    );
    
    background_controller (
        .clk(clk_25mhz),
        .hcount(hcount),
        .vcount(vcount),
        .background_pixel(background_pixel)
    );
    
    bgd_sprite_mux pixel_mux (
        .rst(reset_rtl_0),
        .background_pixel(background_pixel),
        .sprite_pixel(sprite_pixel),
        .sprite_on(sprite_on),
        .final_pixel_index(write_index)
    );


    // Framebuffer wrapper: combines BRAM and palette lookup 
    framebuffer_wrapper fb (
        .clk(clk_25mhz),
        .we(1'b1),
        .write_x(hcount),
        .write_y(vcount),
        .write_index(write_index),
        .read_x(drawX),
        .read_y(drawY),
        .read_color(pixel_color)
    );
    
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

    // Output RGB only during active video region
    logic [3:0] red, green, blue;
    assign red   = pixel_color[11:8];
    assign green = pixel_color[7:4];
    assign blue  = pixel_color[3:0];

endmodule