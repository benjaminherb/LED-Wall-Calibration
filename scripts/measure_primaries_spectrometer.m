%% USER INPUT

% Mac: DEVICE = "/dev/cu.usbmodem11301";
DEVICE = "/dev/ttyACM0"; % check with 'serialportlist'
MEASUREMENT_LABELS = ["WHITE", "RED", "GREEN", "BLUE"]; % list length = amount of measurements
OUTPUT_DIR = "../";

%% PREREQUISITES

MES_DIR = OUTPUT_DIR + "measurements/";
if not(isfolder(MES_DIR))
    mkdir(MES_DIR)
end

%% SERIAL PORT 
try
    % may need privilidged execution
    SM = serialport(DEVICE, 115200);

    % increase timeout, to avoid stopping the readout before the measurement ends
    SM.Timeout = 30;
    
    disp("Connection successful");

catch exception
    switch exception.identifier
        case 'serialport:serialport:ConnectionFailed'
            disp("CONNECTION FAILED");
            disp(exception.message);
            disp("You can check connected devices with 'serialportlist' or run with priviliges if permission was denied ");
            return;
        otherwise
            disp("UNKNOWN EXCEPTION (" + connection.identifier + ")");
            disp(exception.message);
            return;
    end
end


%% REMOTE MODE

% entering remote mode, commands have to be sent as single chars
write(SM, 'P',"uint8");
write(SM, 'H',"uint8");
write(SM, 'O',"uint8");
write(SM, 'T',"uint8");
write(SM, 'O',"uint8");

disp("Remote mode active")

%% MEASUREMENTS

measurements = zeros(201,length(MEASUREMENT_LABELS));

for m=1:length(MEASUREMENT_LABELS)
    
    disp("Start measurement " + MEASUREMENT_LABELS(m) + "?");
    pause; % wait for user input
    disp("Starting measurement in 5 seconds");
    pause(5); % wait 5 seconds before starting
    
    % Measuring CIE 1931 xy
    disp("Measuring CIE 1931 xy");
    write(SM, 'M',"uint8");
    write(SM, '1',"uint8");
    write(SM, char(13),"uint8"); % = [CR] ("newline") to end the command
    
    str = strsplit(readline(SM),',');
    disp(str);
    x = str2num(str(4));
    y = str2num(str(5));
    
    % Measuring CIE 1931 XYZ
    disp("Measuring CIE 1931 XYZ");
    write(SM, 'M',"uint8");
    write(SM, '2',"uint8");
    write(SM, char(13),"uint8"); % = [CR] ("newline") to end the command
    
    str = strsplit(readline(SM),',');
    disp(str);
    X = str2num(str(3));
    Y = str2num(str(4));
    Z = str2num(str(5));
    
    % Measuring CIE uv
    disp("Measuring uv");
    write(SM, 'M',"uint8");
    write(SM, 32',"uint8");
    write(SM, char(13),"uint8"); % = [CR] ("newline") to end the command
    
    str = strsplit(readline(SM),',');
    disp(str);
    u = str2num(str(3));
    v = str2num(str(4));
    
    % Command "M5" returns wavelength and spectral power at each wavelength 
    % (PR670 Manual p.125)
    disp("Measuring Spectral Power Distribution");
    write(SM, 'M',"uint8");
    write(SM, '5',"uint8");
    write(SM, char(13),"uint8"); % = [CR] ("newline") to end the command
    
    wavelengths = NaN(201,1);
    spectralpower = NaN(201,1);
    
    readline(SM) % remove first value
    for i=1:1:201
        str = strsplit(readline(SM),',');
        wavelengths(i,1) = str2num(str(1));
        spectralpower(i,1) = str2num(str(2));
    end
 
    flush(SM) % remove remaining values

    disp("Writing to file");
    output_file = fopen(MES_DIR + 'MEASUREMENT_' + MEASUREMENT_LABELS(m) + '.csv', 'w');
    
    fprintf(output_file, 'X,' + string(X) + '\n\r');
    fprintf(output_file, 'Y,' + string(Y) + '\n\r');
    fprintf(output_file, 'Z,' + string(Z) + '\n\r');
    fprintf(output_file, 'x,' + string(x) + '\n\r');
    fprintf(output_file, 'y,' + string(y) + '\n\r');
    fprintf(output_file, 'u,' + string(u) + '\n\r');
    fprintf(output_file, 'v,' + string(v) + '\n\r');

    
    for k=1:1:201
        fprintf(output_file, string(wavelengths(k)) + ',' + string(spectralpower(k)) + '\n\r');
    end
    
    disp("Finished measurement");
    measurements(:,m) = spectralpower;
    
end

%% FINISH
write(SM, 'Q',"uint8"); % quit remote mode
clear("CU"); % close port

%%
for i= 1:length(MEASUREMENT_LABELS)
    hold on
    disp(i);
    plot(wavelengths, measurements(:,i), MEASUREMENT_LABELS(i)); % labels used for color
end
hold off






