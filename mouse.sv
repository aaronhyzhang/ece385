module cursor_impl (
    input  logic        Reset, 
    input  logic        frame_clk,
    input  logic [31:0] keycode,           // HID packet: [31:24]=unused, [23:16]=x, [15:8]=y, [7:0]=buttons

    output logic [9:0]  CursorX, 
    output logic [9:0]  CursorY, 
    output logic [9:0]  CursorS            // Radius of the cursor
);

    // Parameters for screen bounds
    parameter [9:0] Cursor_X_Center = 320;
    parameter [9:0] Cursor_Y_Center = 240;
    parameter [9:0] Cursor_X_Min    = 0;
    parameter [9:0] Cursor_X_Max    = 639;
    parameter [9:0] Cursor_Y_Min    = 0;
    parameter [9:0] Cursor_Y_Max    = 479;
    parameter [9:0] Cursor_X_Step   = 1;
    parameter [9:0] Cursor_Y_Step   = 1;

    // Cursor state and motion
    logic [9:0] Cursor_X_Motion_next;
    logic [9:0] Cursor_Y_Motion_next;

    logic [9:0] Cursor_X_next;
    logic [9:0] Cursor_Y_next;

    // Extract portions of keycode input
    logic [7:0] x_keycode, y_keycode;
    assign y_keycode = keycode[15:8];
    assign x_keycode = keycode[23:16];

    // Set static cursor size
    assign CursorS = 4;

    always_comb begin
        // Default to no motion
        Cursor_X_Motion_next = 10'd0;
        Cursor_Y_Motion_next = 10'd0;

        // Compute signed motion from USB HID input
        if (x_keycode != 8'h00)
            Cursor_X_Motion_next = { {2{x_keycode[7]}}, x_keycode }; // sign-extend
        if (y_keycode != 8'h00)
            Cursor_Y_Motion_next = { {2{y_keycode[7]}}, y_keycode }; // sign-extend

        // Predict next positions
        Cursor_X_next = CursorX + Cursor_X_Motion_next;
        Cursor_Y_next = CursorY + Cursor_Y_Motion_next;

        // Clamp X within screen bounds
        if (Cursor_X_next + CursorS > Cursor_X_Max)
            Cursor_X_next = Cursor_X_Max - CursorS;
        else if (Cursor_X_next < CursorS)
            Cursor_X_next = CursorS;

        // Clamp Y within screen bounds
        if (Cursor_Y_next + CursorS > Cursor_Y_Max)
            Cursor_Y_next = Cursor_Y_Max - CursorS;
        else if (Cursor_Y_next < CursorS)
            Cursor_Y_next = CursorS;
    end

    // Update position on frame clock
    always_ff @(posedge frame_clk) begin
        if (Reset) begin
            CursorX <= Cursor_X_Center;
            CursorY <= Cursor_Y_Center;
        end else begin
            CursorX <= Cursor_X_next;
            CursorY <= Cursor_Y_next;
        end
    end

endmodule