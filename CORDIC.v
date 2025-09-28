////////////////////////////////////////////////////////////////////////////////
// Name: Shehab Eldeen Khaled
// Course: Chipions Digital Design and FPGA Flow
//
// Description: CORDIC Algorithm
// 
////////////////////////////////////////////////////////////////////////////////

module CORDIC #(parameter WIDTH = 16 , parameter ITERATIONS = 32) (
    input clk,                              // System Clock
    input signed [WIDTH-1:0] x_start,       // Q1.15 (signed) ==> 1-bit for sign , and 15-bits for fraction
    input signed [WIDTH-1:0] y_start,       // Q1.15 (signed) ==> 1-bit for sign , and 15-bits for fraction
    input signed [31:0] angle_after_map,    // Q5.27 (signed) 1-bit for sign ,4-bits for integer part, and 27-bits for fraction part to take the range [-2*pi to 4*pi]
    input sin_sign, cos_sign,               // 1 ==> negative
    output reg signed [WIDTH-1:0] sine,     // Q1.15 (signed) ==> 1-bit for sign , and 15-bits for fraction
    output reg signed [WIDTH-1:0] cosine    // Q1.15 (signed) ==> 1-bit for sign , and 15-bits for fraction
);

// Use larger internal registers to maintain precision
reg signed [31:0] x [0:ITERATIONS];
reg signed [31:0] y [0:ITERATIONS];  
reg signed [31:0] z [0:ITERATIONS];

integer i;

// arctan table Q5.27
localparam signed [31:0] atan_table [0:31] = '{
    32'h06487ED5, // i=0,  atan=0.785398 rad = 45.000000 deg
    32'h03B58CE1, // i=1,  atan=0.463648 rad = 26.565051 deg
    32'h01F5B760, // i=2,  atan=0.244979 rad = 14.036243 deg
    32'h00FEADD5, // i=3,  atan=0.124355 rad =  7.125016 deg
    32'h007FD56F, // i=4,  atan=0.062419 rad =  3.576334 deg
    32'h003FFAAB, // i=5,  atan=0.031240 rad =  1.789911 deg
    32'h001FFF55, // i=6,  atan=0.015624 rad =  0.895174 deg
    32'h000FFFEB, // i=7,  atan=0.007812 rad =  0.447614 deg
    32'h0007FFFD, // i=8,  atan=0.003906 rad =  0.223811 deg
    32'h00040000, // i=9,  atan=0.001953 rad =  0.111906 deg
    32'h00020000, // i=10, atan=0.000977 rad =  0.055953 deg
    32'h00010000, // i=11, atan=0.000489 rad =  0.027976 deg
    32'h00008000, // i=12, atan=0.000244 rad =  0.013988 deg
    32'h00004000, // i=13, atan=0.000122 rad =  0.006994 deg
    32'h00002000, // i=14, atan=0.000061 rad =  0.003497 deg
    32'h00001000, // i=15, atan=0.000031 rad =  0.001749 deg
    32'h00000800, // i=16, atan=0.000015 rad =  0.000874 deg
    32'h00000400, // i=17, atan=0.000008 rad =  0.000437 deg
    32'h00000200, // i=18, atan=0.000004 rad =  0.000219 deg
    32'h00000100, // i=19, atan=0.000002 rad =  0.000109 deg
    32'h00000080, // i=20, atan=0.000001 rad =  0.000055 deg
    32'h00000040, // i=21, atan=0.000000 rad =  0.000027 deg
    32'h00000020, // i=22, atan=0.000000 rad =  0.000014 deg
    32'h00000010, // i=23, atan=0.000000 rad =  0.000007 deg
    32'h00000008, // i=24, atan=0.000000 rad =  0.000003 deg
    32'h00000004, // i=25, atan=0.000000 rad =  0.000002 deg
    32'h00000002, // i=26, atan=0.000000 rad =  0.000001 deg
    32'h00000001, // i=27, atan=0.000000 rad =  0.000000 deg
    32'h00000000, // i=28, atan=0.000000 rad =  0.000000 deg
    32'h00000000, // i=29, atan=0.000000 rad =  0.000000 deg
    32'h00000000, // i=30, atan=0.000000 rad =  0.000000 deg
    32'h00000000  // i=31, atan=0.000000 rad =  0.000000 deg
};

always @(posedge clk) begin
    // Initialize with extended precision (convert Q1.15 to Q1.30 equivalent)
    // Sign extend and shift left by 15 bits to increase accuracy
    x[0] <= {{1{x_start[WIDTH-1]}}, x_start, 15'b0};
    y[0] <= {{1{y_start[WIDTH-1]}}, y_start, 15'b0};
    z[0] <= angle_after_map;

    // CORDIC iterations
    for (i = 0; i < ITERATIONS; i = i + 1) begin
        if (z[i][31] == 1'b1) begin     // negative angle
            x[i+1] <= x[i] + (y[i] >>> i);
            y[i+1] <= y[i] - (x[i] >>> i);
            z[i+1] <= z[i] + atan_table[i];
        end
        else begin                      // positive angle
            x[i+1] <= x[i] - (y[i] >>> i);
            y[i+1] <= y[i] + (x[i] >>> i);
            z[i+1] <= z[i] - atan_table[i];
        end
    end
    
    // Final output
    // Convert from extended precision back to Q1.15 by taking bits [30:15] ==> bit[30] is the integer bit and rest is fraction
    if (sin_sign) begin
        sine <= -y[ITERATIONS][30:15];  // we doesn't take the bit[31] , as we handle the sign separately
    end else begin
        sine <= y[ITERATIONS][30:15];
    end
    
    if (cos_sign) begin
        cosine <= -x[ITERATIONS][30:15];
    end else begin
        cosine <= x[ITERATIONS][30:15];
    end
end
endmodule