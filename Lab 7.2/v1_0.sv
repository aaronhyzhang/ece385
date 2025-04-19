//Provided HDMI_Text_controller_v1_0 for HDMI AXI4 IP 
//Fall 2024 Distribution

//Modified 3/10/24 by Zuofu
//Updated 11/18/24 by Zuofu


`timescale 1 ns / 1 ps

module hdmi_text_controller_v1_0 #
(1

    // Parameters of Axi Slave Bus Interface S00_AXI
    // Modify parameters as necessary for access of full VRAM range

    parameter integer C_AXI_DATA_WIDTH	= 32,
    parameter integer C_AXI_ADDR_WIDTH	= 16
)
(
    // Users to add ports here

    output logic hdmi_clk_n,
    output logic hdmi_clk_p,
    output logic [2:0] hdmi_tx_n,
    output logic [2:0] hdmi_tx_p,

    // User ports ends
    // Do not modify the ports beyond this line

    // Ports of Axi Slave Bus Interface AXI
    input logic  axi_aclk,
    input logic  axi_aresetn,
    input logic [C_AXI_ADDR_WIDTH-1 : 0] axi_awaddr,
    input logic [2 : 0] axi_awprot,
    input logic  axi_awvalid,
    output logic  axi_awready,
    input logic [C_AXI_DATA_WIDTH-1 : 0] axi_wdata,
    input logic [(C_AXI_DATA_WIDTH/8)-1 : 0] axi_wstrb,
    input logic  axi_wvalid,
    output logic  axi_wready,
    output logic [1 : 0] axi_bresp,
    output logic  axi_bvalid,
    input logic  axi_bready,
    input logic [C_AXI_ADDR_WIDTH-1 : 0] axi_araddr,
    input logic [2 : 0] axi_arprot,
    input logic  axi_arvalid,
    output logic  axi_arready,
    output logic [C_AXI_DATA_WIDTH-1 : 0] axi_rdata,
    output logic [1 : 0] axi_rresp,
    output logic  axi_rvalid,
    input logic  axi_rready
);

//additional logic variables as necessary to support VGA, and HDMI modules.
    logic clk_25MHz, clk_125MHz, locked, hsync, vsync, vde;
    logic [9:0] drawX, drawY;
    logic [3:0] red, green, blue;

    logic [9:0] row, col, pixelX, pixelY;
    logic [11:0] coord;
    logic [10:0] regNum;
//    logic        byteNum;
    logic [31:0] calcData;
    
    assign col = drawX >> 3; // divide by 8
    assign row = drawY >> 4; // divide by 16
    
    assign pixelX = drawX & 10'b0000000111; // mod 8
    assign pixelY = drawY & 10'b0000001111; // mod 16
    
    assign coord = (row * 80) + col; //row major order coordinate of the grid currently being drawn on
    
    
    //Lab 7.2 version
    logic byteNum;
    assign regNum = coord[11:1]; //divide by 2 (bc 2 data bytes per data word in VRAM
    assign byteNum = coord[0]; //mod 2  
    
    //Lab 7.1 version
//    logic [1:0] byteNum;
//    assign regNum[10] = 1'b0;
//    assign regNum = coord[11:2]; //divide by 4 (bc 4 data bytes per data word in VRAM
//    assign byteNum = coord[1:0]; //mod 4 
      
    
//    logic [31:0] palette[16];
    logic [3:0] FGD_idx, BGD_idx;
    logic [11:0] FGD_color, BGD_color;


    // Instantiation of Axi Bus Interface AXI
    hdmi_text_controller_v1_0_AXI # ( 
        .C_S_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH)
    ) hdmi_text_controller_v1_0_AXI_inst (
        .S_AXI_ACLK(axi_aclk),
        .S_AXI_ARESETN(axi_aresetn),
        .S_AXI_AWADDR(axi_awaddr),
        .S_AXI_AWPROT(axi_awprot),
        .S_AXI_AWVALID(axi_awvalid),
        .S_AXI_AWREADY(axi_awready),
        .S_AXI_WDATA(axi_wdata),
        .S_AXI_WSTRB(axi_wstrb),
        .S_AXI_WVALID(axi_wvalid),
        .S_AXI_WREADY(axi_wready),
        .S_AXI_BRESP(axi_bresp),
        .S_AXI_BVALID(axi_bvalid),
        .S_AXI_BREADY(axi_bready),
        .S_AXI_ARADDR(axi_araddr),
        .S_AXI_ARPROT(axi_arprot),
        .S_AXI_ARVALID(axi_arvalid),
        .S_AXI_ARREADY(axi_arready),
        .S_AXI_RDATA(axi_rdata),
        .S_AXI_RRESP(axi_rresp),
        .S_AXI_RVALID(axi_rvalid),
        .S_AXI_RREADY(axi_rready),
//        .controlData(controlData),
        .calcData(calcData),
        .calcAddr(regNum),
    //Lab 7.2 ports
        .FGD_idx(FGD_idx),
        .BGD_idx(BGD_idx),
        .FGD_color(FGD_color),
        .BGD_color(BGD_color)
    );

//Instiante clocking wizard, VGA sync generator modules, and VGA-HDMI IP here. For a hint, refer to the provided
//top-level from the previous lab. You should get the IP to generate a valid HDMI signal (e.g. blue screen or gradient)
//prior to working on the text drawing.

    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(~axi_aresetn),
        .locked(locked),
        .clk_in1(axi_aclk)
    );
    
    //VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(~axi_aresetn),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),           // need to
        .drawX(drawX),              // divided by 16
        .drawY(drawY)               // divided by 8
    );    

    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(~axi_aresetn),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_clk_p),          
        .TMDS_CLK_N(hdmi_clk_n),          
        .TMDS_DATA_P(hdmi_tx_p),         
        .TMDS_DATA_N(hdmi_tx_n)          
    );
    
    //Lab 7.2 version
    color_mapper color_instance(
        .byteNum(byteNum),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .data(calcData),
        .Red(red),
        .Green(green),
        .Blue(blue),
        .FGD_idx(FGD_idx),
        .BGD_idx(BGD_idx),
        .FGD_color(FGD_color),
        .BGD_color(BGD_color)
    );
    
    //Lab 7.1 version
//    color_mapper color_instance(
//        .byteNum(byteNum),
//        .pixelX(pixelX),
//        .pixelY(pixelY),
//        .data(calcData),
//        .Red(red),
//        .Green(green),
//        .Blue(blue)
//    );

// User logic ends

endmodule
