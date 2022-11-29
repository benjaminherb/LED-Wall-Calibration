%% SETUP

clear

% USER CONFIG

conf.data_dir ="../measurements/response_curve/";
conf.gamma = 2.2;
conf.bit_depth= 8;
conf.intermediate_colorspace = "linear-rgb"; % eg. "srgb" (default) | "adobe-rgb-1998" | "prophoto-rgb" | "linear-rgb"


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

% SPLIT GREY CURVE TO RGB
response_curves_rgb_split = NaN(4, conf.value_length);
json_text = fileread(string(files(1).folder) + "/" + string(files(1).name));
data = jsondecode(json_text);
ref_lum = data(end).Yxy.Y;

for j = 1:1:length(data')
    if (data(j).Yxy.value == "-0008") % in accurate readings
        response_curves_absolute(:,j) = 0;
    else
        rgb = xyz2rgb([...
            data(j).XYZ.X / ref_lum, ...
            data(j).XYZ.Y / ref_lum, ...
            data(j).XYZ.Z / ref_lum], ...
            "ColorSpace", conf.intermediate_colorspace);
        
        grey = data(j).XYZ.Y / ref_lum;
        red = rgb2xyz([rgb(1), 0, 0], "ColorSpace", conf.intermediate_colorspace);
        green = rgb2xyz([0, rgb(2), 0], "ColorSpace", conf.intermediate_colorspace);
        blue =rgb2xyz([0, 0, rgb(3)], "ColorSpace", conf.intermediate_colorspace);
        
        response_curves_rgb_split(:,j) = [grey, red(2), green(2), blue(2)];
    end
end

for i = 1:height(response_curves_rgb_split)
    response_curves_rgb_split(i,:) = response_curves_rgb_split(i,:) ./ response_curves_rgb_split(i, end);
end

clear("rc", "i", "j", "json_text", "files", "data", "grey", "red", "green", "blue", "rgb"); % clear temp variables

%% PLOT
figure("Name", "Response Curve Comparison", "NumberTitle", "off", "Position", [0 0 1000 1000] );
tiledlayout(2,2);

plot_full_and_detail(values_absolute, response_curves_scaled, reference_curve, 'RGB Channels Measured Separately');
plot_full_and_detail(values_absolute, response_curves_rgb_split, reference_curve, 'RGB Channels From Grey Curve');


%% HELPER FUNCTIONS
function plot_full_and_detail(values, response_curves, reference_curve, name)
% FULL PLOT
first = nexttile;
plot(values, reference_curve, 'black:' ...
    , values, response_curves(1,:), 'black' ...
    , values, response_curves(2,:), 'red' ...
    , values, response_curves(3,:), 'green' ...
    , values, response_curves(4,:), 'blue' ...
    );

legend('gamma 2.2','white','red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Output [0-1]');
xlim([0 255]);
title(first, name);


% DETAIL
second = nexttile;
plot(values, reference_curve, 'black:' ...
    , values, response_curves(1,:), 'black' ...
    , values, response_curves(2,:), 'red' ...
    , values, response_curves(3,:), 'green' ...
    , values, response_curves(4,:), 'blue' ...
    );

legend('gamma 2.2','white','red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Output [0-1]');
xlim([235 255]);
ylim([0.90 1.01]);
title(second, name);
end