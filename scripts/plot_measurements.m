clear;

addpath("../utils");

conf.data_dir ="../measurements/other/";
conf.files = dir(conf.data_dir + "/*.json")';
conf.value_whitepoint = [255,255,255];
conf.plot_type = "scatter"; % scatter or trisurf

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

%plot_v01(conf, measurements, whitepoint)
plot_v02(measurements, whitepoint)
%plot_v03(measurements, whitepoint)


%%
function plot_v03(measurements, whitepoint)

figure("Name", "LED Wall Measurements", "NumberTitle", "off", "Position", [0 0 1200 500] );
tiledlayout(1,2);

nexttile;
hold on;
grid on;
measured_values = convert_measurements(measurements, whitepoint, "XYZ");
plot_colorspace(measured_values, "PQuv", "trisurf");
plot_colorspace(get_values("cie1931"), "PQuv", "projection-boundary");
%plot_colorspace(get_values("mesh", "rec2020", 32, 1000), "PQuv", "scatter", 10000);
%plot_colorspace(get_values("mesh", "srgb", 32, 300), "PQuv", "scatter", 10000);
title("PQu'v'");
show_cdm2_values_for_pq(10000);
hold off;

nexttile;
hold on;
grid on;
peak_luminance = 10000;
measured_values = convert_measurements(measurements, whitepoint, "XYZ");
plot_colorspace(measured_values, "ICtCp", "trisurf");
plot_colorspace(get_values("cie1931"), "ICtCp", "projection-boundary");
plot_colorspace(get_values("mesh", "rec2020", 32, 10), "ICtCp", "scatter");
%plot_colorspace(get_values("mesh", "srgb", 32, 300), "ICtCp", "scatter");
title("ICtCp");
show_cdm2_values_for_pq(10000);
hold off;
end



%%

function plot_v01(conf, measurements, whitepoint)

figure("Name", "LED Wall Measurements", "NumberTitle", "off", "Position", [0 0 1200 500] );
tiledlayout(1,3);

nexttile;
hold on;
grid on;
measured_values = convert_measurements(measurements, whitepoint, "XYZ");
plot_colorspace(measured_values, "PQuv", "trisurf");
plot_colorspace(get_values("cie1931"), "PQuv", "projection-boundary");
plot_colorspace(get_values("mesh", "rec2020", 32), "PQuv", "projection-boundary");
plot_colorspace(get_values("mesh", "srgb", 32), "PQuv", "projection-boundary");
title("PQu'v'");
show_cdm2_values_for_pq(10000);
hold off;

nexttile;
hold on;
grid on;
measured_values = convert_measurements(measurements, whitepoint, "XYZ");
%plot_colorspace(measured_values, "ICtCp", "trisurf");
%plot_colorspace(get_values("cie1931"), "ICtCp", "projection-boundary");
plot_colorspace(get_values("mesh", "rec2020", 32), "ICtCp", "scatter");
%plot_colorspace(get_values("mesh", "srgb", 32), "ICtCp", "scatter");
title("ICtCp");
show_cdm2_values_for_pq(10000);
hold off;

nexttile;
end
%%
function plot_v02(measurements, whitepoint)
tiledlayout(1,3);

nexttile;
hold on;
grid on;
plot_colorspace(get_values("hue"), "lab", "hue-projection");
%plot_colorspace(get_values("hue"), "lab", "hue-curves");
plot_colorspace(get_values("mesh", "srgb", 32), "lab", "projection-boundary");
title("CIELAB");
%show_cdm2_values_for_pq(10000);
hold off;

nexttile;
hold on;
grid on;
plot_colorspace(get_values("hue"), "PQuv", "hue-projection");
%plot_colorspace(get_values("hue"), "lab", "hue-curves");
plot_colorspace(get_values("mesh", "srgb", 32), "PQuv", "projection-boundary");
title("PQu'v'");
show_cdm2_values_for_pq(10000);
hold off;

nexttile;
hold on;
grid on;
plot_colorspace(get_values("hue"), "ICtCp", "hue-projection");
%plot_colorspace(get_values("hue"), "lab", "hue-curves");
plot_colorspace(get_values("mesh", "srgb", 32), "ICtCp", "projection-boundary");
title("ICtCp");
show_cdm2_values_for_pq(10000);
hold off;
end



%%
function plot_values(values, type)
if type == "scatter"
    scatter3(values(:,2), values(:,3), values(:, 1), 50, values(:,4:6)./255, '.');
elseif type == "trisurf"
    [tri_idx, ~] = convhull(values(:,2), values(:,3), values(:, 1));
    vol = trisurf(tri_idx, values(:,2), values(:,3), values(:, 1), 'EdgeColor', 'interp', 'FaceColor', 'none');
    vol.FaceVertexCData = values(:,4:6) ./255;
end
end

function show_cdm2_values_for_pq(max_value)
linear_ztick = [0.1, 0.3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10000];
ztick = NaN(size(linear_ztick));
for i = 1:1:length(linear_ztick)
    ztick(i) = linear_to_PQ(linear_ztick(i), max_value);
end
set(gca, 'ZTick', ztick, 'ZTickLabel', linear_ztick);
hold off;
end


