////////////////////////////////////////////////////////////////////////////////
// Name: Shehab Eldeen Khaled
// Course: Chipions Digital Design and FPGA Flow
//
// Description: CORDIC Algorithm Top Module
// 
////////////////////////////////////////////////////////////////////////////////

module CORDIC_top #(parameter WIDTH = 16 , parameter ITERATIONS = 32) (
    input clk,
    input signed [WIDTH-1:0] x_start,
    input signed [WIDTH-1:0] y_start,
    input signed [31:0] angle_in,
    output signed [WIDTH-1:0] sine,
    output signed [WIDTH-1:0] cosine
);

wire signed [31:0] angle_cordic_out;
wire sin_sign, cos_sign;

quad_logic quad_logic_DUT(
    .angle_in(angle_in),
    .angle_cordic_out(angle_cordic_out),
    .sin_sign(sin_sign),
    .cos_sign(cos_sign)
);

CORDIC #(.WIDTH(WIDTH), .ITERATIONS(ITERATIONS)) CORDIC_DUT(
    .clk(clk),
    .x_start(x_start),
    .y_start(y_start),
    .angle_after_map(angle_cordic_out),
    .sin_sign(sin_sign),
    .cos_sign(cos_sign),
    .sine(sine),
    .cosine(cosine)
);

endmodule