function CORDIC_model()
    % CORDIC MATLAB Reference Model
    
    fprintf('=== CORDIC MATLAB Reference Model ===\n');
    
    % 1) Corner cases (degrees)
    corner_cases = [0, 90, 180, 270, 360];
    
    % 2) Overflow and Underflow (degrees)
    overflow_cases = [450, -120];
    
    % 3) Boundary conditions (degrees)
    boundary_cases = [720, -360];
    
    % 4) Random tests positive (degrees)
    random_positive = [30,37,45,60,102,120,135,150,190,210,225,250,300,315,340,40.6,100.3,220.4,350.7];
    
    % 5) Random tests negative (degrees)
    random_negative = [-30,-37,-45,-60,-102,-120,-135,-150,-190,-210,-225,-250,-300,-315,-340,-40.6,-100.3,-220.4,-350.7];
    
    % Combine all 
    all_angles = [corner_cases, overflow_cases, boundary_cases, random_positive, random_negative];
    
    % Create file to put results in it
    filename = 'MATLAB_outputs.txt';
    fileID = fopen(filename, 'w');
    if fileID == -1
        if ispc
            docs_folder = fullfile(getenv('USERPROFILE'), 'Documents');
        else
            docs_folder = fullfile(getenv('HOME'), 'Documents');
        end
        filename = fullfile(docs_folder, 'MATLAB_outputs.txt');
        fileID = fopen(filename, 'w');
    end
    
    if fileID == -1
        fprintf('File can not be created\n');
    else
        % File opened successfully - proceed with normal writing
        fprintf('File created successfully: %s\n', filename);
        
        % Display detailed results on screen AND write to file
        fprintf('\n1) CORNER CASES (0,90,180,270,360)\n');
        fprintf('Angle_deg Sine_Hex Cosine_Hex Sine_Real Cosine_Real\n');
        for i = 1:length(corner_cases)
            angle_deg = corner_cases(i);
            [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg);
            fprintf('%9.1f %8s %10s %9.6f %10.6f\n', angle_deg, sine_hex, cosine_hex, sine_real, cosine_real);
            fprintf(fileID, '%.6f %.6f\n', sine_real, cosine_real);
        end
        
        fprintf('\n2) OVERFLOW AND UNDERFLOW (450,-120)\n');
        fprintf('Angle_deg Sine_Hex Cosine_Hex Sine_Real Cosine_Real\n');
        for i = 1:length(overflow_cases)
            angle_deg = overflow_cases(i);
            [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg);
            fprintf('%9.1f %8s %10s %9.6f %10.6f\n', angle_deg, sine_hex, cosine_hex, sine_real, cosine_real);
            fprintf(fileID, '%.6f %.6f\n', sine_real, cosine_real);
        end
        
        fprintf('\n3) BOUNDARY CONDITIONS (720,-360)\n');
        fprintf('Angle_deg Sine_Hex Cosine_Hex Sine_Real Cosine_Real\n');
        for i = 1:length(boundary_cases)
            angle_deg = boundary_cases(i);
            [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg);
            fprintf('%9.1f %8s %10s %9.6f %10.6f\n', angle_deg, sine_hex, cosine_hex, sine_real, cosine_real);
            fprintf(fileID, '%.6f %.6f\n', sine_real, cosine_real);
        end
        
        fprintf('\n4) RANDOM TESTS POSITIVE\n');
        fprintf('Angle_deg Sine_Hex Cosine_Hex Sine_Real Cosine_Real\n');
        for i = 1:length(random_positive)
            angle_deg = random_positive(i);
            [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg);
            fprintf('%9.1f %8s %10s %9.6f %10.6f\n', angle_deg, sine_hex, cosine_hex, sine_real, cosine_real);
            fprintf(fileID, '%.6f %.6f\n', sine_real, cosine_real);
        end
        
        fprintf('\n5) RANDOM TESTS NEGATIVE\n');
        fprintf('Angle_deg Sine_Hex Cosine_Hex Sine_Real Cosine_Real\n');
        for i = 1:length(random_negative)
            angle_deg = random_negative(i);
            [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg);
            fprintf('%9.1f %8s %10s %9.6f %10.6f\n', angle_deg, sine_hex, cosine_hex, sine_real, cosine_real);
            fprintf(fileID, '%.6f %.6f\n', sine_real, cosine_real);
        end
        fclose(fileID);
    end
end

function [sine, cosine, sine_real, cosine_real, sine_hex, cosine_hex] = process_angle(angle_deg)

    [sine, cosine] = cordic_algorithm(angle_deg);
    
    % Convert to real values
    sine_real = double(sine) / 32768;
    cosine_real = double(cosine) / 32768;
    
    % Convert to hexa
    sine_hex = dec2hex(typecast(sine, 'uint16'), 4);
    cosine_hex = dec2hex(typecast(cosine, 'uint16'), 4);
end

function [sine, cosine] = cordic_algorithm(angle_deg)

    % Fixed-point formats
    Q5_27_SCALE = 2^27;  % 32-bit angle: 5 integer + 27 fractional
    
    % Some Q5.27 constants 
    PI = int32(hex2dec('1921FB54'));     % pi in Q5.27
    PI_2 = int32(hex2dec('0C90FDAA'));   % pi/2 in Q5.27  
    TWO_PI = int32(hex2dec('3243F6A9')); % 2*pi in Q5.27
    Kn = int16(hex2dec('4DBA'));         % Scaling factor in Q1.15
    
    % Convert angle to Q5.27
    angle_rad = deg2rad(angle_deg);
    angle_in = int32(angle_rad * Q5_27_SCALE);
    
    % Quadrant mapping
    if angle_in < 0
        angle_norm = angle_in + TWO_PI;
    elseif angle_in >= TWO_PI
        angle_norm = angle_in - TWO_PI;
    else
        angle_norm = angle_in;
    end
    
    % Determine quadrant and adjust angle
    if angle_norm <= PI_2           % 1st quadrant
        angle_cordic = angle_norm;
        sin_sign = 0;   % sin positive
        cos_sign = 0;   % cos positive
    elseif angle_norm <= PI         % 2nd quadrant  
        angle_cordic = PI - angle_norm;
        sin_sign = 0;   % sin positive
        cos_sign = 1;   % cos negative
    elseif angle_norm <= PI+PI_2    % 3rd quadrant
        angle_cordic = angle_norm - PI;
        sin_sign = 1;   % sin negative
        cos_sign = 1;   % cos negative
    else                            % 4th quadrant
        angle_cordic = TWO_PI - angle_norm;
        sin_sign = 1;   % sin negative
        cos_sign = 0;   % cos positive
    end
    
    % atan table (Q5.27)
    atan_table = int32([
        hex2dec('06487ED5'), hex2dec('03B58CE1'), hex2dec('01F5B760'), ...
        hex2dec('00FEADD5'), hex2dec('007FD56F'), hex2dec('003FFAAB'), ...
        hex2dec('001FFF55'), hex2dec('000FFFEB'), hex2dec('0007FFFD'), ...
        hex2dec('00040000'), hex2dec('00020000'), hex2dec('00010000'), ...
        hex2dec('00008000'), hex2dec('00004000'), hex2dec('00002000'), ...
        hex2dec('00001000'), hex2dec('00000800'), hex2dec('00000400'), ...
        hex2dec('00000200'), hex2dec('00000100'), hex2dec('00000080'), ...
        hex2dec('00000040'), hex2dec('00000020'), hex2dec('00000010'), ...
        hex2dec('00000008'), hex2dec('00000004'), hex2dec('00000002'), ...
        hex2dec('00000001'), hex2dec('00000000'), hex2dec('00000000'), ...
        hex2dec('00000000'), hex2dec('00000000')
    ]);
    
    x_start = Kn;  % Q1.15
    y_start = int16(0);
    
    % Initialize with extended precision (convert Q1.15 to Q1.30 equivalent)
    % Sign extend and shift left by 15 bits
    x = int32(x_start) * int32(32768);  % Convert Q1.15 to Q1.30
    y = int32(y_start) * int32(32768);  % Convert Q1.15 to Q1.30
    z = angle_cordic;
    
    % CORDIC iterations (32)
    for i = 1:32
        if z < 0
            x_next = x + bitsra(y, i-1);
            y_next = y - bitsra(x, i-1);
            z_next = z + atan_table(i);
        else
            x_next = x - bitsra(y, i-1);
            y_next = y + bitsra(x, i-1);
            z_next = z - atan_table(i);
        end
        x = x_next;
        y = y_next;
        z = z_next;
    end
    
    % Convert back to Q1.15 (take bits [30:15])
    sine_temp = int16(bitsra(y, 15));   % bit shift right arithmetic by 15 bits
    cosine_temp = int16(bitsra(x, 15));
    
    % Apply quadrant correction
    if sin_sign
        sine = -sine_temp;
    else
        sine = sine_temp;
    end
    
    if cos_sign
        cosine = -cosine_temp;
    else
        cosine = cosine_temp;
    end
end