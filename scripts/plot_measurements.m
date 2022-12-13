clear;

addpath("../utils");

conf.data_dir ="../measurements/other/";
conf.files = dir(conf.data_dir + "/*.json")';
conf.value_whitepoint = [255,255,255];
conf.plot_type = "trisurf"; % scatter or trisurf

%%
clear("measurements");

for i = 1:1:length(conf.files)
    new_measurement = jsondecode(fileread(string(conf.files(i).folder) + "/" + string(conf.files(i).name)));
    
    % hacky but works
    if (i == 1)
        measurements = new_measurement;
    else
        for j = 1:1:length(new_measurement)
            measurements(end+1) = new_measurement(j);
        end
    end
end

for i = 1:1:length(measurements)
    if measurements(i).measurement == conf.value_whitepoint
        whitepoint = measurements(i);
    end
end

clear("json_text", "new_measurement", "i", "j");

%%
figure("Name", "LED Wall Measurements CIELUV and CIELAB", "NumberTitle", "off", "Position", [0 0 1200 500] );
tiledlayout(1,3);

nexttile;
hold on;
grid on;
values = convert_measurements(measurements, whitepoint, "luv");
plot_values(values, conf.plot_type);
plot_colorspace("visible-spectrum", "luv", "mesh", 32, "scatter");
title('CIELUV vs Visible Spectrum (1931 2° Standard Observer)');
hold off;

nexttile;
hold on;
grid on;
values = convert_measurements(measurements, whitepoint, "lab");
plot_values(values, conf.plot_type);
plot_colorspace("visible-spectrum", "lab", "mesh", 32, "scatter");
title('CIELAB vs Visible Spectrum (1931 2° Standard Observer)');
hold off;

nexttile;
hold on;
grid on;
values = convert_measurements(measurements, whitepoint, "PQuv");
plot_values(values, conf.plot_type);
%plot_colorspace("visible-spectrum", "lab", "mesh", 32, "scatter");
hold off;


%%
function plot_values(values, type)
if type == "scatter"
    scatter3(values(:,2), values(:,3), values(:, 1), 50, values(:,4:6)./255, '.');
elseif type == "trisurf"
    [tri_idx, ~] = convhull(values(:,2), values(:,3), values(:, 1));
    vol = trisurf(tri_idx, values(:,2), values(:,3), values(:, 1), 'EdgeColor', 'none', 'FaceColor', 'interp');
    vol.FaceVertexCData = values(:,4:6) ./255;
end
end
