function plot_colorspace(colorspace, colormodel, value_type, precision, plot_type)
values = get_values(value_type, precision);
% values = get_black_to_white_test_values();
% values = get_all_values(); % ALL the values

% D65
[Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);


if colorspace == "visible-spectrum"
    values = get_visible_spectrum();
    values_color = values(:,4:6);
end
values_converted = NaN(length(values), 3);


for i = 1:1:length(values)
    if colorspace == "srgb"
        XYZ = RGB_to_XYZ(values(i,1),values(i,2), values(i,3), "srgb", "D65", "srgb");
    elseif colorspace == "visible-spectrum"
        XYZ = values(i,1:3);
    end
    
    if colormodel == "luv"
        [v1,v2,v3] = XYZ_to_LUV(XYZ(1),XYZ(2), XYZ(3), Xw, Yw, Zw);
    elseif colormodel == "lab"
        [v1,v2,v3] = XYZ_to_LAB(XYZ(1),XYZ(2), XYZ(3), Xw, Yw, Zw);
    end
    
    values_converted(i,1:3) = [v1,v2,v3];
end
if colorspace == "srgb"
    values_color = values;
end

if plot_type == "scatter"
    scatter3(values_converted(:,2), values_converted(:,3), values_converted(:, 1), 50, values_color, '.');
elseif plot_type == "trisurf"
    [TriIdx, ~] = convhull(values_converted(:,2), values_converted(:,3), values_converted(:, 1));
    vol = trisurf(TriIdx, values_converted(:,2), values_converted(:,3), values_converted(:, 1), 'EdgeColor', 'none', 'FaceColor', 'interp');
    vol.FaceVertexCData = values_color;
end
end

function values = get_visible_spectrum()
data = csvread("../data/CIE_xyz_1931_2deg.csv");
values = data(68:end-142,2:4);
disp(min(data(68:end-142,1)))
disp(max(data(68:end-142,1)))

for i = 1:1:length(values)
    RGB = XYZ_to_RGB(values(i,1),values(i,2), values(i,3), "srgb", "D65", "srgb");
    values(i,4:6) = RGB;
end
end


function values = get_values(type, steps)

i = 1;
for r = 0:1/steps:1
    for g = 0:1/steps:1
        for b = 0:1/steps:1
            if type == "borders"
                valid_value = ((r == 0 || r == 1) && g == b) || ...
                    ((g == 0 || g == 1) && r == b) || ...
                    ((b == 0 || b == 1) && r == g) || ...
                    ((r == 0 || r == 1) && (g == 0 || g == 1)) || ...
                    ((r == 0 || r == 1) && (b == 0 || b == 1)) || ...
                    ((b == 0 || b == 1) && (g == 0 || g == 1));
            elseif type == "primary-borders"
                valid_value = ...
                    ((g == 0) && (b == 0)) ||  ...
                    ((r == 0) && (b == 0)) ||  ...
                    ((g == 0) && (r == 0)) || ...
                    ((r == 1) && (g == b)) || ...
                    ((g == 1) && (r == b)) || ...
                    ((b == 1) && (r == g));
                
            elseif type == "mesh"
                valid_value = (r == 0 || r == 1 || g == 0 || g == 1 || b == 0 || b == 1);
            elseif type == "all"
                valid_value = 1;
            end
            
            if valid_value
                values(i,: ) = [r, g, b];
                i = i+1;
            end
        end
    end
end
end