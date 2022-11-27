%% USER CONFIG

conf.data_dir ="../measurements/response_curve/";
conf.gamma = 2.2;

%% PREREQUISITES

files = dir(conf.data_dir + "/*.json")';
response_curves = NaN(256, length(files));
for i = 1:1:length(files)
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data = jsondecode(json_text);
    
    for j = 1:1:length(data')
        response_curves(j,i) = data(j).Yxy.Y;
    end
end

%% PLOT

values = 0:1:255;
scaled_values = values ./255;
reference_curve = scaled_values .^ conf.gamma;

figure();
plot(values, reference_curve, 'cyan');
hold on
plot(values, response_curves(:,1) ./ response_curves(end, 1), 'black');
plot(values, response_curves(:,2) ./ response_curves(end, 2), 'red');
plot(values, response_curves(:,3) ./ response_curves(end, 3), 'green');
plot(values, response_curves(:,4) ./ response_curves(end, 4), 'blue');
hold off
legend('reference','white','red','green','blue');
%%





fig_abs = figure('Name', 'Gamma Curve compared to measured response curve');

% MEASURED RESPONSE CURVE (Scaled Y Values)
plot(data.Value, measured_curve, 'black'); % labels used for color
hold on
% REFERENCE GAMMA CURVE
plot(data.Value, reference_curve, 'red');
plot(data.Value, reference_26, 'green');


%% DIFFERENCE

fig_dev = figure('Name', 'Measured deviation from reference gamma');
plot(values, reference_curve - measured_curve);

%% GENERATE SIMPLE OFFSET LUT


if not(isfolder(OUTPUT_DIR))
    mkdir(OUTPUT_DIR)
end

TS_STR = datestr(datetime,'yyyymmdd_HHMMss_');

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

