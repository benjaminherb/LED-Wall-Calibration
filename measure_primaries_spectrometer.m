%% USER INPUT

OUT_DIR = "./out/";
MEASUREMENT_LABELS = ["RED", "GREEN", "BLUE"];

%% PREREQUISITES

MES_DIR = OUTPUT_DIR + "/MEASUREMENTS/";
if not(isfolder(MES_DIR))
    mkdir(MES_DIR)
end

%% SERIAL PORT 

% check with 'serialportlist', may need privilidged execution
SM = serialport("/dev/ttyACM0", 115200);

% increase timeout, to avoid stopping the readout before the measurement ends
SM.Timeout = 30; 

%% REMOTE MODE

% commands are sent as single chars
write(SM, 'P',"uint8");
write(SM, 'H',"uint8");
write(SM, 'O',"uint8");
write(SM, 'T',"uint8");
write(SM, 'O',"uint8");

disp("Remote mode active...")

measureIndex = 1;
measure = zeros(17,201);

%% MEASUREMENTS

measurements = NaN(201:lenght(MEASUREMENT_LABELS));


for i=1:length(measurements)
    
    disp("Start measurement: " + MEASUREMENT_LABELS(i) + "?");
    pause; % wait for user input
    pause(5); % wait 5 seconds before starting
    
    % Command "M5" returns wavelength and spectral power at each wavelength 
    % (PR670 Manual p.125)
    write(SM, 'M',"uint8");
    write(SM, '5',"uint8");
    write(SM, char(13),"uint8"); % = [CR] ("newline") to end the command
    
    wavelengths = NaN(201,1);
    spectralpower = NaN(201,1);
    
    readline(SM) % remove first value
    for j = 1:1:201
        str = strsplit(readline(SM),',');
        wavelengths(j,1) = str2num(str(1));
        spectralpower(j,1) = str2num(str(2));
        flush(SM) % remove remaining values
    end
    
    disp("Writing to file");
    output_file = fopen(MES_DIR + 'MEASUREMENT_' + MEASUREMENT_LABELS(i) + '.csv', 'w');
    for k=1:1:201
        fprintf(output_file, string(wavelengths(k)) + ',' + string(spectralpower(k)) + '\n\r');
    end
    
    disp("Finished measurement");
    measurements(i) = spectralpower;
end

write(SM, 'Q',"uint8"); % quit remote mode
clear("CU"); % close port

%% PLOTTING THE RESULT

for i= 1:length(measurements)
    hold on
    plot(measurements(i), spectralpower);
end
hold off






