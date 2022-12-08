%% SETUP

clear

% USER CONFIG

conf.data_dir ="../measurements/response_curve/";
conf.gamma = 2.2;
conf.bit_depth= 8;
conf.intermediate_colorspace = "linear-rgb"; % eg. "srgb" (default) | "adobe-rgb-1998" | "linear-rgb"


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

% DIFF FOR MEASURED CURVES
response_curves_measured_diff = NaN(size(response_curves_scaled));
for i = 1:height(response_curves_scaled)
    response_curves_measured_diff(i,:) = response_curves_scaled(i,:) - reference_curve;
end

% RELATIVE DIV FOR MEASURED CURVES
%reference_curve_scaled = NaN(size(response_curves_scaled));
%for i = 1:height(response_curves_scaled)
%    reference_curve_scaled(i,:) = reference_curve .* response_curves_absolute(:,end);
%end
%response_curves_relative_diff = NaN(size(response_curves_scaled));
%for i = 1:height(response_curves_scaled)
%    response_curves_relative_diff(i,:) = response_curves_absolute(i,:) ./ reference_curve_scaled(i,:);
%end


% SPLIT GREY CURVE TO RGB
json_text = fileread(string(files(1).folder) + "/" + string(files(1).name));
data = jsondecode(json_text);
response_curves_rgb_split = split_to_rgb(data, conf.intermediate_colorspace);


% DIFF FOR SPLIT CURVES
response_curves_split_diff = NaN(size(response_curves_rgb_split));
for i = 1:height(response_curves_scaled)
    response_curves_split_diff(i,:) = response_curves_rgb_split(i,:) - reference_curve;
end


% COMPARE ERROR FROM CHOOSING DIFFERENT INTERMEDIATE COLOR SPACES
rc_rgb_srgb = split_to_rgb(data, "srgb");
rc_rgb_lin = split_to_rgb(data, "linear-rgb");
srgb_linrgb_diff = rc_rgb_srgb - rc_rgb_lin;



clear("rc", "i", "j", "json_text", "files", "data"); % clear temp variables

%% PLOT
figure("Name", "Response Curve Comparison", "NumberTitle", "off", "Position", [0 0 1920 1000] );
tiledlayout(2,4);

nexttile();
plot_curves(values_absolute, response_curves_scaled, ...
    reference_curve, 'RGB Channels Measured Separately', [0 255], [0 1]);

nexttile();
plot_curves(values_absolute, response_curves_scaled, ...
    reference_curve, 'RGB Channels Measured Separately (Detail)', [235 255], [0.90 1.01]);

nexttile();
plot(values_absolute, response_curves_measured_diff(1,:), 'black' ...
    , values_absolute, response_curves_measured_diff(2,:), 'red' ...
    , values_absolute, response_curves_measured_diff(3,:), 'green' ...
    , values_absolute, response_curves_measured_diff(4,:), 'blue' ...
    );

legend('grey', 'red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Difference Output [0-1]');
xlim([0 255]);
title('Difference between measured (separately) and expected');

nexttile();
plot(values_absolute, srgb_linrgb_diff(2,:), 'red' ...
    , values_absolute, srgb_linrgb_diff(3,:), 'green' ...
    , values_absolute, srgb_linrgb_diff(4,:), 'blue' ...
    );

legend('red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Difference Output [0-1]');
xlim([0 255]);
title('sRGB vs linRGB Diff (interm. CS)');


nexttile();
plot_curves(values_absolute, response_curves_rgb_split, ...
    reference_curve, 'RGB Channels From Grey Curve', [0 255], [0 1]);

nexttile();
plot_curves(values_absolute, response_curves_rgb_split, ...
    reference_curve, 'RGB Channels From Grey Curve (Detail)', [235 255], [0.90 1.01]);

nexttile();
plot(values_absolute, response_curves_split_diff(1,:), 'black' ...
    , values_absolute, response_curves_split_diff(2,:), 'red' ...
    , values_absolute, response_curves_split_diff(3,:), 'green' ...
    , values_absolute, response_curves_split_diff(4,:), 'blue' ...
    );

legend('grey', 'red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Difference Output [0-1]');
xlim([0 255]);
title('Difference between measured (split) and expected');

nexttile();

plot(values_absolute, response_curves_measured_diff(1,:) * response_curves_absolute(1,end), 'black' ...
    , values_absolute, response_curves_measured_diff(2,:)* response_curves_absolute(2,end), 'red' ...
    , values_absolute, response_curves_measured_diff(3,:)* response_curves_absolute(3,end), 'green' ...
    , values_absolute, response_curves_measured_diff(4,:)* response_curves_absolute(4,end), 'blue' ...
);

legend('grey', 'red','green','blue', 'location', 'northwest');
xlabel('Input Code Value [0-255]');
ylabel('Measured Luminance Difference Output cd/m²');
xlim([0 255]);
title('Difference Absolute');


%plot(values_absolute, response_curves_relative_diff(1,:), 'black' ...
%    , values_absolute, response_curves_relative_diff(2,:), 'red' ...
%    , values_absolute, response_curves_relative_diff(3,:), 'green' ...
%    , values_absolute, response_curves_relative_diff(4,:), 'blue' ...
%);

%legend('grey', 'red','green','blue', 'location', 'northwest');
%xlabel('Input Code Value [0-255]');
%ylabel('Measured Luminance relative Difference Output');
%xlim([0 255]);
%ylim([0 10]);
%title('Difference Relative');
%% HELPER FUNCTIONS

function response_curves_rgb_split = split_to_rgb(data, colorspace)
response_curves_rgb_sprlit = NaN(4, length(data'));

ref_lum = data(end).Yxy.Y;

for j = 1:1:length(data')
    if (data(j).Yxy.value == "-0008") % in accurate readings
        response_curves_rgb_split(:,j) = 0;
    else
        rgb = xyz2rgb([...
            data(j).XYZ.X / ref_lum, ...
            data(j).XYZ.Y / ref_lum, ...
            data(j).XYZ.Z / ref_lum], ...
            "ColorSpace", colorspace);
        
        grey = data(j).XYZ.Y / ref_lum;
        red = rgb2xyz([rgb(1), 0, 0], "ColorSpace", colorspace);
        green = rgb2xyz([0, rgb(2), 0], "ColorSpace", colorspace);
        blue =rgb2xyz([0, 0, rgb(3)], "ColorSpace", colorspace);
        
        response_curves_rgb_split(:,j) = [grey, red(2), green(2), blue(2)];
    end
end

for i = 1:height(response_curves_rgb_split)
    response_curves_rgb_split(i,:) = response_curves_rgb_split(i,:) ./ response_curves_rgb_split(i, end);
end
end

function plot_curves(values, response_curves, reference_curve, name, xlimit, ylimit)

plot(values, reference_curve, 'black:' ...
    , values, response_curves(1,:), 'black' ...
    , values, response_curves(2,:), 'red' ...
    , values, response_curves(3,:), 'green' ...
    , values, response_curves(4,:), 'blue' ...
    );

legend('gamma 2.2','white','red','green','blue', 'location', 'northwest');
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