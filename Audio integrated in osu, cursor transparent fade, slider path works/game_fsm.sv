`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 11:50:00 PM
// Design Name: 
// Module Name: game_fsm
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


module game_fsm (
    input  logic clk,
    input  logic rst_n,
    input  logic start_btn,     // from your pushbutton or mouse click
    input  logic play_done,     // asserted by osu_top when sequence finishes
    output logic [1:0] state    // 0=MENU,1=PLAY,2=END
);

  typedef enum logic [1:0] {
    S_MENU = 2'd0,
    S_PLAY = 2'd1,
    S_END  = 2'd2
  } state_t;

  state_t current, next;

  // state register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)      current <= S_MENU;
    else             current <= next;
  end

  // next-state logic
  always_comb begin
    next = current;
    unique case (current)
      S_MENU: if (start_btn)  next = S_PLAY;
      S_PLAY: if (play_done)  next = S_END;
      S_END : if (start_btn)  next = S_MENU;
    endcase
  end

  assign state = current;

endmodule
