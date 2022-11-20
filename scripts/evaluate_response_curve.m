%% USER CONFIG

DATA_FILE="/home/ben/Code/LED-Wall-Calibration/measurements/auto_measure/TEST.csv";
GAMMA = 2.2;
FILE_NAME = "MY_NEWEST_LUT";
OUTPUT_DIR = "../output/LUTS/";

%% PREREQUISITES

if not(isfolder(OUTPUT_DIR))
    mkdir(OUTPUT_DIR)
end

TS_STR = datestr(datetime,'yyyymmdd_HHMMss_');
data = readtable(DATA_FILE);

% scaled to highest value = 1 and lowest value = 0
measured_curve = (data.Y - data.Y(1)) ./ (data.Y(end)-data.Y(1));
values = data.Value ./ 255;
reference_curve = values .^ GAMMA;

fig_abs = figure('Name', 'Gamma Curve compared to measured response curve');

% MEASURED RESPONSE CURVE (Scaled Y Values)
plot(values, measured_curve, 'black'); % labels used for color
hold on
% REFERENCE GAMMA CURVE
plot(values, reference_curve, 'red');

%% DIFFERENCE

fig_dev = figure('Name', 'Measured deviation from reference gamma');
plot(values, reference_curve - measured_curve);

%% GENERATE SIMPLE OFFSET LUT

GAMMA_STR = string(GAMMA*10); % used for filenames/start of gamdat file

offset_curve = reference_curve + (reference_curve - measured_curve);
offset_curve = offset_curve .* 2^16;
offset_curve = uint16(offset_curve);

output_file = fopen(OUTPUT_DIR + TS_STR + FILE_NAME + ".gamdat", 'w');
fprintf(output_file, GAMMA_STR + '*0#255#0#65535#');

first_number = 1; % Avoid the comma at the eof
for i = 1:1:length(offset_curve)
    if(first_number)
        fprintf(output_file, string(offset_curve(i)));
        first_number = 0;
    else
        fprintf(output_file, "," + string(offset_curve(i)));
    end
end

