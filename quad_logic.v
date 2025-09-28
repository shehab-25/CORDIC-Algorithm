////////////////////////////////////////////////////////////////////////////////
// Name: Shehab Eldeen Khaled
// Course: Chipions Digital Design and FPGA Flow
//
// Description: Quadrature Logic Mapper
// 
////////////////////////////////////////////////////////////////////////////////

module quad_logic (
    input signed [31:0] angle_in,              // Q5.27 to take the range [-2*pi to 4*pi]
    output reg signed [31:0] angle_cordic_out, // Q5.27 mapped to [-pi/2, +pi/2]
    output reg sin_sign, cos_sign             // 1 means negative
);

// Q5.27 constants
localparam signed [31:0] PI = 32'h1921FB54;           // pi
localparam signed [31:0] PI_2 = 32'h0C90FDAA;         // pi/2
localparam signed [31:0] TWO_PI = 32'h3243F6A9;       // 2*pi
localparam signed [31:0] THREE_PI_2 = 32'h25B2F8FE;   // 3*pi/2

reg signed [31:0] angle_norm;

always @(*) begin
    // Normalize the input angle to be in [0:2*pi]
    if (angle_in < 0) begin
        angle_norm = angle_in + TWO_PI;
    end
    else if (angle_in >= TWO_PI) begin
        angle_norm = angle_in - TWO_PI;
    end
    else begin
        angle_norm = angle_in;
    end

    // Map the normalized angle to be in [-pi/2:pi/2] 
    if (angle_norm <= PI_2) begin  // 1st quad (0 to 90°)
        angle_cordic_out = angle_norm;
        sin_sign = 1'b0;  // sin positive
        cos_sign = 1'b0;  // cos positive
    end
    else if (angle_norm <= PI) begin  // 2nd quad (90° to 180°)
        angle_cordic_out = PI - angle_norm;
        sin_sign = 1'b0;  // sin positive
        cos_sign = 1'b1;  // cos negative
    end
    else if (angle_norm <= THREE_PI_2) begin  // 3rd quad (180° to 270°)
        angle_cordic_out = angle_norm - PI;
        sin_sign = 1'b1;  // sin negative
        cos_sign = 1'b1;  // cos negative
    end
    else begin  // 4th quad (270° to 360°)
        angle_cordic_out = TWO_PI - angle_norm;
        sin_sign = 1'b1;  // sin negative
        cos_sign = 1'b0;  // cos positive
    end
end
endmodule