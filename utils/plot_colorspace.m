function plot_colorspace(colorspace, colormodel, value_type, precision)
values = get_values(value_type, precision);
% values = get_black_to_white_test_values();
% values = get_all_values(); % ALL the values

values_converted = NaN(length(values), 3);
% D65
[Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);

for i = 1:1:length(values)
    if colorspace == "srgb"
        XYZ = RGB_to_XYZ(values(i,1),values(i,2), values(i,3), "srgb", "D65", "srgb");
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


scatter3(values_converted(:,2), values_converted(:,3), values_converted(:, 1), 50, values_color, '.');

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
                valid_value = ((r == 0 || r == 1) && g == b) || ...
                    ((g == 0 || g == 1) && r == b) || ...
                    ((b == 0 || b == 1) && r == g);
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