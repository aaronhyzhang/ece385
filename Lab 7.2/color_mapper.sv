//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Zuofu Cheng   08-19-2023                               --
//                                                                       --
//    Fall 2023 Distribution                                             --
//                                                                       --
//    For use with ECE 385 USB + HDMI                                    --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper ( input  logic [9:0] pixelX, pixelY,
                       input  logic       byteNum,             //2 bits for Lab 7.1, 1 bit for lab 7.2
                       input  logic [31:0] data,
                       output logic [3:0]  Red, Green, Blue,
                       output logic [3:0] FGD_idx, BGD_idx,         //used in Lab 7.2
                       input logic [11:0] FGD_color, BGD_color
                        );	 
  
///////////////////////////////////////
//Lab 7.1 code

    logic [7:0] glyph, glyphRow;
    logic [3:0] FGD_idx, BGD_idx;
    
    always_comb
    begin
        case (byteNum)
            1'b0 :
            begin
                glyph = data[15:8];
                FGD_idx = data[7:4];
                BGD_idx = data[3:0];
            end
            1'b1 :
            begin
                glyph = data[31:24];
                FGD_idx = data[23:20];
                BGD_idx = data[19:16];
            end
            default : 
            begin
                glyph = 8'h00;
                FGD_idx = 4'h0;
                BGD_idx = 4'h0;
            end
         endcase
    end
    
    logic [10:0] address;
    assign address[10:4] = glyph[6:0];
    assign address[3:0] = pixelY;
    
    font_rom font (
            .addr(address),     //try x10010
            .data(glyphRow)     //glyphRow had a row of data from the glyph we are on and the row we are on
    );
    
    always_comb
    begin
        //check FGD or BGD     glyph[7] is inversion bit
        if(glyph[7] ^ glyphRow[7-pixelX])  //glyphRow[pixelX] is data of pixel to be drawn from cur glyph
        begin
            Red = FGD_color[11:8];
            Green = FGD_color[7:4];
            Blue = FGD_color[3:0];
        end
        else
        begin
            Red = BGD_color[11:8];
            Green = BGD_color[7:4];
            Blue = BGD_color[3:0];
        end
    end
    
    
    
////////////////////////////////////////////////////////////
// Lab 7.1 code
//    logic [7:0] glyph, glyphRow;
    
//    always_comb
//    begin
//        case (byteNum)
//            2'b00 : glyph = data[7:0];
//            2'b01 : glyph = data[15:8];
//            2'b10 : glyph = data[23:16];
//            2'b11 : glyph = data[31:24];
//            default : glyph = 8'h00;
//         endcase
//    end
    
//    logic [10:0] address;
//    assign address[10:4] = glyph[6:0];
//    assign address[3:0] = pixelY;
    
//    font_rom font (
//            .addr(address),     //try x10010
//            .data(glyphRow)     //glyphRow had a row of data from the glyph we are on and the row we are on
//    );

//    logic [31:0] controlData;
//    assign controlData = 32'h001F6000;
//    always_comb
//    begin
//        //check FGD or BGD     glyph[7] is inversion bit
//        if(glyph[7] ^ glyphRow[7-pixelX])  //glyphRow[pixelX] is data of pixel to be drawn from cur glyph
//        begin
//            Red = controlData[24:21];
//            Green = controlData[20:17];
//            Blue = controlData[16:13];
//        end
//        else
//        begin
//            Red = controlData[12:9];
//            Green = controlData[8:5];
//            Blue = controlData[4:1];
//        end
//    end
    

endmodule
