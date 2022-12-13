% SETUP

clear

% USER CONFIG

conf.data_dir_linux ="../measurements/response_curve/";
conf.data_dir_windows = "../measurements/response_curve_windows/";
conf.gamma = 2.2;
conf.bit_depth= 8;
conf.intermediate_colorspace = "linear-rgb"; % eg. "srgb" (default) | "adobe-rgb-1998" | "linear-rgb"


% PREPARATION
conf.value_length = 2 ^ conf.bit_depth;
conf.max_value = conf.value_length - 1;

response_curves_linux.absolute = load_data(conf.data_dir_linux);
response_curves_windows.absolute = load_data(conf.data_dir_windows);

values.absolute = 0:1:conf.max_value;
values.scaled = values.absolute / conf.max_value;
reference_curve = values.scaled .^ conf.gamma;

response_curves_linux.scaled = NaN(size(response_curves_linux.absolute));
for i = 1:height(response_curves_linux.absolute)
    response_curves_linux.scaled(i,:) = response_curves_linux.absolute(i,:) ./ response_curves_linux.absolute(i, end);
end

response_curves_windows.scaled = NaN(size(response_curves_windows.absolute));
for i = 1:height(response_curves_windows.absolute)
    response_curves_windows.scaled(i,:) = response_curves_windows.absolute(i,:) ./ response_curves_windows.absolute(i, end);
end

diff.linux = response_curves_linux.scaled ./ reference_curve;
diff.windows = response_curves_windows.scaled ./ reference_curve;

clear("data", "i","j","json_text");

%% PLOT
figure("Name", "Response Curve Comparison", "NumberTitle", "off", "Position", [0 0 1920 1000] );
tiledlayout(2,4);

nexttile();
plot_curves(values.absolute, response_curves_linux.scaled, ...
    reference_curve, 'RGB Channels Linux', [0 255], [0 1]);
nexttile();
plot_curves(values.absolute, response_curves_linux.scaled, ...
    reference_curve, 'RGB Channels Linux', [165 175], [0.37 0.47]);

nexttile();
plot_curves(values.absolute, response_curves_linux.scaled, ...
    reference_curve, 'RGB Channels Linux', [235 255], [0.90 1.01]);

nexttile();
plot_curves(values.absolute, diff.linux, ...
    ones(256), 'Relative Difference Linux', [165 255], [0.95 1.08], "southwest");


nexttile();
plot_curves(values.absolute, response_curves_windows.scaled, ...
    reference_curve, 'RGB Channels Windows', [0 255], [0 1]);

nexttile();
plot_curves(values.absolute, response_curves_windows.scaled, ...
    reference_curve, 'RGB Channels Windows', [165 175], [0.37 0.47]);

nexttile();
plot_curves(values.absolute, response_curves_windows.scaled, ...
    reference_curve, 'RGB Channels Windows', [235 255], [0.90 1.01]);

nexttile();
plot_curves(values.absolute, diff.windows, ...
    ones(256), 'Relative Difference Windows', [165 255], [0.95 1.08], "southwest");


%% HELPER FUNCTIONS

function plot_curves(values, response_curves, reference_curve, name, xlimit, ylimit, location)
if ~exist('location', 'var')
    location = "northwest";
end


plot(values, reference_curve, 'black' ...
    , values, response_curves(1,:), 'black' ...
    , values, response_curves(2,:), 'red' ...
    , values, response_curves(3,:), 'green' ...
    , values, response_curves(4,:), 'blue' ...
    );


legend('gamma 2.2','white','red','green','blue', 'location', location);
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Output [0-1]');
if ~isempty(xlimit)
    xlim(xlimit);
end
if ~isempty(ylimit)
    ylim(ylimit);
end
title(name);
end

function response_curves = load_data(data_dir)
% LOAD DATA

files = dir(data_dir + "/*.json")';
response_curves = NaN(4,256);

for i = 1:1:length(files)
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data = jsondecode(json_text);
    if contains(files(i).name, "grey")
        pos = 1;
    elseif contains(files(i).name, "red")
        pos = 2;
    elseif contains(files(i).name, "green")
        pos = 3;
    elseif contains(files(i).name, "blue")
        pos = 4;
    end
    
    for k = 1:1:length(data')
        if ~(data(k).Yxy.value == "-0008")
            response_curves(pos, max(data(k).measurement) + 1) = data(k).XYZ.Y;
        end
    end
end
end
