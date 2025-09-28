////////////////////////////////////////////////////////////////////////////////
// Name: Shehab Eldeen Khaled
// Course: Chipions Digital Design and FPGA Flow
//
// Description: CORDIC Algorithm Testbench
// 
////////////////////////////////////////////////////////////////////////////////

module CORDIC_tb ();
    // Signal Declaration
    parameter WIDTH = 16;
    reg clk;
    reg signed [WIDTH-1:0] x_start , y_start;  // Q1.15 (signed) ==> 1bit for sign , and rest for fractional
    reg signed [31:0] angle_in;                // Q5.27 (signed) 1bit for sign ,4bits for integer part, and the rest for fraction part
    wire signed [WIDTH-1:0] sine , cosine;     // Q1.15 (signed) represent sin and cos [-1:1] ==> 1bit for sign , and rest for fractional
    real sine_real, cosine_real;
    real angle_rad, angle_deg;

    localparam signed [WIDTH-1:0] Kn = 16'h4DBA; // Q1.15 (signed) Kn = 0.6072529351 

    // Q5.27 constants for angle generation
    localparam signed [31:0] PI = 32'h1921FB54;           // pi
    localparam signed [31:0] TWO_PI = 32'h3243F6A9;       // 2*pi
    localparam signed [31:0] NEG_TWO_PI = 32'hCDBC0958;   // -2*pi
    localparam signed [31:0] FOUR_PI = 32'h6487ED52;      // 4*pi
    integer i = 0;
    integer pos_angles [0:18];   // to store random angles
    
    // File handling variables
    integer matlab_file;
    integer file_status;
    integer test_case_count = 0;
    
    // MATLAB reference results storage and compare it with verilog results
    real matlab_sine_real [0:50];  // Store up to 50 test cases
    real matlab_cosine_real [0:50];
    
    // Error calculation variables
    real sine_error, cosine_error;
    real sine_error_percent, cosine_error_percent;
    real max_sine_error = 0, max_cosine_error = 0;

    // module instantiation
    CORDIC_top DUT_top(clk,x_start,y_start,angle_in,sine,cosine);

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #2 clk = ~clk;
        end
    end

    // Read MATLAB outputs file
    initial begin
        matlab_file = $fopen("MATLAB_outputs.txt", "r");
        if (matlab_file == 0) begin
            $display("Error: Could not open MATLAB_outputs.txt file!");
            $stop;
        end
        
        $display("\nReading MATLAB reference results");
        
        // Read all test cases from file 
        test_case_count = 0;
        while (!$feof(matlab_file) && test_case_count < 50) begin
            file_status = $fscanf(matlab_file, "%f %f", 
                matlab_sine_real[test_case_count],
                matlab_cosine_real[test_case_count]);
            
            if (file_status == 2) begin // Successfully read 2 values
                test_case_count = test_case_count + 1;
            end
        end
        $fclose(matlab_file);
        $display("Read %0d test cases from MATLAB_outputs.txt", test_case_count);
    end

    // Task to run a test case and compare with MATLAB
    task run_test_case;
        input [31:0] angle;
        input integer matlab_index;
        begin
            angle_in = angle;
            #150; // Wait for CORDIC computation
            
            // Calculate errors
            sine_error = sine_real - matlab_sine_real[matlab_index];
            cosine_error = cosine_real - matlab_cosine_real[matlab_index];
            
            // Calculate error percentage
            if (matlab_sine_real[matlab_index] != 0) begin
                sine_error_percent = (sine_error / matlab_sine_real[matlab_index]) * 100;
            end else begin
                sine_error_percent = (sine_error != 0) ? 999.9 : 0.0;
            end
            
            if (matlab_cosine_real[matlab_index] != 0) begin
                cosine_error_percent = (cosine_error / matlab_cosine_real[matlab_index]) * 100;
            end else begin
                cosine_error_percent = (cosine_error != 0) ? 999.9 : 0.0;
            end
            
            // Update error statistics
            if (sine_error_percent < 0) sine_error_percent = -sine_error_percent;
            if (cosine_error_percent < 0) cosine_error_percent = -cosine_error_percent;
            
            if (sine_error_percent > max_sine_error) max_sine_error = sine_error_percent;
            if (cosine_error_percent > max_cosine_error) max_cosine_error = cosine_error_percent;
            
            $display("%4t %10.1f %10.6f  %12h %10.6f  %10.6f  %11h %11h %10.2f%% %10.2f%%", 
                     $time, angle_deg, angle_rad, angle_in, 
                     sine_real, cosine_real, sine, cosine,
                     sine_error_percent, cosine_error_percent);
        end
    endtask

    //Stimulus generation
    initial begin
        x_start = Kn;
        y_start = 0; // always zero
        
        // Wait for file to be read
        #20;

        $display("\n================================= CORDIC Algorithm Testbench ==========================================\n");
        $display("----------------------------------------- Corner Cases ------------------------------------------\n");
        $display("Time Angle(Deg) Angle(Rad)  Angle(Q5.27) Sine(Real)  Cos(Real)   Sine(Q1.15) Cos(Q1.15) Sine_Err(%%) Cos_Err(%%)");
        $display("---- ---------- ----------  ------------ ----------  ----------  ----------- ----------- ---------- ----------\n");

        // Initialize error statistics
        max_sine_error = 0;
        max_cosine_error = 0;

        // ------------------------------------Corner Cases------------------------------------------------
        // Test cases must match the order in your MATLAB_outputs.txt file
        run_test_case(32'h00000000, 0);  // 0 deg 
        run_test_case(32'h0C90FDAA, 1);  // 90 deg
        run_test_case(32'h1921FB54, 2);  // 180 deg
        run_test_case(32'h25B2F8FF, 3);  // 270 deg
        run_test_case(32'h3243F6A9, 4);  // 360 deg

        // ---------------------------------------------Overflow and Underflow-----------------------------------------------
        $display("\n----------------------------------------- Overflow and Underflow ------------------------------------------\n");
        $display("Time Angle(Deg) Angle(Rad)  Angle(Q5.27) Sine(Real)  Cos(Real)   Sine(Q1.15) Cos(Q1.15) Sine_Err(%%) Cos_Err(%%)");
        $display("---- ---------- ----------  ------------ ----------  ----------  ----------- ----------- ---------- ----------\n");
        
        run_test_case(32'h3ED4F453, 5);  // 450 deg
        run_test_case(32'hEF3EADC8, 6);  // -120 deg
        // -------------------------------------Boundary conditions [-2*pi to 4*pi]-----------------------------------------------
        $display("\n----------------------------------------- Boundary conditions ------------------------------------------\n");
        $display("Time Angle(Deg) Angle(Rad)  Angle(Q5.27) Sine(Real)  Cos(Real)   Sine(Q1.15) Cos(Q1.15) Sine_Err(%%) Cos_Err(%%)");
        $display("---- ---------- ----------  ------------ ----------  ----------  ----------- ----------- ---------- ----------\n");
        
        run_test_case(32'h6487ED51, 7);  // 720 deg
        run_test_case(32'hCDBC0957, 8);  // -360 deg

        // ----------------------------------------------Random Positive Angles------------------------------------------------------
        $display("\n------------------------------------ Random Positive Angles --------------------------------------------------\n");
        $display("Time Angle(Deg) Angle(Rad)  Angle(Q5.27) Sine(Real)  Cos(Real)   Sine(Q1.15) Cos(Q1.15) Sine_Err(%%) Cos_Err(%%)");
        $display("---- ---------- ----------  ------------ ----------  ----------  ----------- ----------- ---------- ----------\n");
        
        // Random angles starting from index 9 in MATLAB file
        pos_angles[0] = 32'h0431FBD4;   // 30 deg
        pos_angles[1] = 32'h052A8A6E;   // 37 deg
        pos_angles[2] = 32'h06487ED5;   // 45 deg
        pos_angles[3] = 32'h0860A91D;   // 60 deg
        pos_angles[4] = 32'h0E3DEC4A;   // 102 deg
        pos_angles[5] = 32'h10C15239;   // 120 deg
        pos_angles[6] = 32'h12D97C80;   // 135 deg
        pos_angles[7] = 32'h14F1A6C7;   // 150 deg
        pos_angles[8] = 32'h1A876CD9;   // 190 deg
        pos_angles[9] = 32'h1D524FE3;   // 210 deg
        pos_angles[10] = 32'h1F6A7A2A;  // 225 deg
        pos_angles[11] = 32'h22E815F5;  // 250 deg
        pos_angles[12] = 32'h29E34D8D;  // 300 deg
        pos_angles[13] = 32'h2BFB77D4;  // 315 deg
        pos_angles[14] = 32'h2F7913A0;  // 340 deg
        // Floating point angles
        pos_angles[15] = 32'h05AB3868;   // 40.6 deg
        pos_angles[16] = 32'h0E01285A;   // 100.3 deg
        pos_angles[17] = 32'h1EC60DA0;   // 220.4 deg
        pos_angles[18] = 32'h30F78A87;   // 350.7 deg
        
        for (i = 0; i < 19; i = i + 1) begin
            run_test_case(pos_angles[i], 9+i);
        end

        // ----------------------------------------------Random Negative Angles------------------------------------------------------
        $display("\n------------------------------------ Random Negative Angles --------------------------------------------------\n");
        $display("Time Angle(Deg) Angle(Rad)  Angle(Q5.27) Sine(Real)  Cos(Real)   Sine(Q1.15) Cos(Q1.15) Sine_Err(%%) Cos_Err(%%)");
        $display("---- ---------- ----------  ------------ ----------  ----------  ----------- ----------- ---------- ----------\n");
        
        for (i = 0; i < 19; i = i + 1) begin
            run_test_case(-pos_angles[i], 28+i);
        end

        $display("\n================================= ERROR STATISTICS ==========================================\n");
        $display("Maximum Sine Error:     %0.2f%%", max_sine_error);
        $display("Maximum Cosine Error:   %0.2f%%", max_cosine_error);
        $display("====================================== End of Testing =================================================\n");
        $stop;
    end

    // generate real values of angle in rad and degrees
    always @(angle_in) begin
        angle_rad = $itor($signed(angle_in)) / (1.0 * (1<<27));
        angle_deg = angle_rad * (180.0 / 3.141592653589793);
    end

    // generate real values of sine and cosine
    always @(sine or cosine) begin
        sine_real = $itor($signed(sine)) / 32768.0;
        cosine_real = $itor($signed(cosine)) / 32768.0;
    end
    
endmodule