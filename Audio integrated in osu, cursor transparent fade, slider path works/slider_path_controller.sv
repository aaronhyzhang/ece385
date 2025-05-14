`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2025 04:34:13 PM
// Design Name: 
// Module Name: slider_path_controller
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


module slider_path_controller (
    input  logic        clk,
    input  logic [9:0]  drawX,
    input  logic [8:0]  drawY,
    input  logic [9:0]  start_x,
    input  logic [8:0]  start_y,
    input  logic [9:0]  end_x,
    input  logic [8:0]  end_y,
    input  logic        enable,
    output logic        path_on
);
    // make radius of path width adjustable if desired
    parameter PATH_WIDTH = 4;

    logic signed [10:0] dx, dy;
    logic [21:0] dist_sq;
    logic [9:0] px;
    logic [8:0] py;

    assign px = drawX;
    assign py = drawY;


    always_comb begin
        path_on = 1'b0;
    
        if (enable) begin
            int sx = start_x;
            int sy = start_y;
            int ex = end_x;
            int ey = end_y;
            int px = drawX;
            int py = drawY;
            
            int cros, num, denom, dist_sq;
    
            // Early exit: bounding box filter
            int min_x = (sx < ex) ? sx : ex;
            int max_x = (sx > ex) ? sx : ex;
            int min_y = (sy < ey) ? sy : ey;
            int max_y = (sy > ey) ? sy : ey;
    
            if (px >= min_x - PATH_WIDTH && px <= max_x + PATH_WIDTH &&
                py >= min_y - PATH_WIDTH && py <= max_y + PATH_WIDTH) begin
    
                // Cross product to get signed area = twice the triangle area
                int dx = ex - sx;
                int dy = ey - sy;
                int dx1 = px - sx;
                int dy1 = py - sy;
    
                cros = dx * dy1 - dy * dx1;
                num = cros * cros;
                denom = dx*dx + dy*dy;
    
                // Distance squared from point to line
                dist_sq = (denom != 0) ? (num / denom) : 0;
    
                if (dist_sq <= PATH_WIDTH * PATH_WIDTH) begin
                    path_on = 1'b1;
                end
            end
        end
    end 

//    always_comb begin
//        path_on = 1'b0;
    
//        if (enable) begin
//            // Use integer types for math
//            int sx, sy, ex, ey, px, py;
//            int dx, dy, len_sq, t_num, t_fixed;
//            int proj_x, proj_y;
//            int ddx, ddy, dist_sq;
    
//            sx = start_x;
//            sy = start_y;
//            ex = end_x;
//            ey = end_y;
//            px = drawX;
//            py = drawY;
    
//            dx = ex - sx;
//            dy = ey - sy;
//            len_sq = dx*dx + dy*dy;
    
    
//            // project (px,py) onto the line segment using fixed-point math (scaled by 1024)
//            t_num = ((px - sx) * dx + (py - sy) * dy) * 1024;
//            t_fixed = t_num / len_sq;
    
//            // clamp to [0, 1024]
//            if (t_fixed < 0) t_fixed = 0;
//            if (t_fixed > 1024) t_fixed = 1024;
    
//            proj_x = sx + ((dx * t_fixed) >>> 10); // >>> to preserve sign
//            proj_y = sy + ((dy * t_fixed) >>> 10);
    
//            ddx = px - proj_x;
//            ddy = py - proj_y;
//            dist_sq = ddx*ddx + ddy*ddy;
    
//            if (dist_sq <= PATH_WIDTH * PATH_WIDTH)
//                path_on = 1'b1;
    
//        end
//    end
endmodule
