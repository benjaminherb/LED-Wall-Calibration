%% SETUP

clear

% USER CONFIG

conf.data_dir ="../measurements/response_curve/";
conf.gamma = 2.2;
conf.bit_depth= 8;


% PREPARATION

conf.value_length = 2 ^ conf.bit_depth;
conf.max_value = conf.value_length - 1;


% LOAD DATA

files = dir(conf.data_dir + "/*.json")';
response_curves_absolute = NaN(length(files), conf.value_length);
for i = 1:1:length(files)
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data = jsondecode(json_text);
    
    for j = 1:1:length(data')
        if (data(j).Yxy.value == "-0008") % in accurate readings
            response_curves_absolute(i,j) = 0;
        else
            response_curves_absolute(i,j) = data(j).Yxy.Y;
        end
    end
end

values_absolute = 0:1:conf.max_value;
values_scaled = values_absolute / conf.max_value;
reference_curve = values_scaled .^ conf.gamma;
response_curves_scaled = NaN(size(response_curves_absolute));
for i = 1:height(response_curves_absolute)
    response_curves_scaled(i,:) = response_curves_absolute(i,:) ./ response_curves_absolute(i, end);
end

clear("rc", "i", "j", "json_text", "files"); % clear temp variables

%% PLOT
figure("Name", "Response Curve Comparison", "NumberTitle", "off", "Position", [0 0 1300 600] );
tiledlayout(1,2);


% FULL PLOT
full_range = nexttile;

plot(values_absolute, reference_curve, 'black:' ...
, values_absolute, response_curves_scaled(1,:), 'black' ...
, values_absolute, response_curves_scaled(2,:), 'red' ...
, values_absolute, response_curves_scaled(3,:), 'green' ...
, values_absolute, response_curves_scaled(4,:), 'blue' ...
);

legend('gamma 2.2','white','red','green','blue');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Output [0-1]');
xlim([0 255]);

% DETAIL
detail_range = nexttile;

plot(values_absolute, reference_curve, 'black:' ...
, values_absolute, response_curves_scaled(1,:), 'black' ...
, values_absolute, response_curves_scaled(2,:), 'red' ...
, values_absolute, response_curves_scaled(3,:), 'green' ...
, values_absolute, response_curves_scaled(4,:), 'blue' ...
);

legend('gamma 2.2','white','red','green','blue');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Output [0-1]');
xlim([240 255]);
ylim([0.95 1.05]);