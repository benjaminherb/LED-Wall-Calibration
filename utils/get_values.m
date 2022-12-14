function values = get_values(type, colorspace, steps)
% returns X,Y,Z,R,G,B (standard sRGB for visualisation)

if type == "visible_spectrum" || type == "cie1931" || type == "1931"
    values = get_visible_spectrum("cie1931");
    return;
elseif type == "cie1964" || type == "1964"
    values = get_visible_spectrum("cie1964");
    return;
end


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
                values(i,4:6) = [r, g, b];
                i = i+1;
            end
        end
    end
end

for i = 1:1:length(values)
    if colorspace == "srgb"
        values(i,1:3) = RGB_to_XYZ(values(i,4),values(i,5), values(i,6), "srgb", "D65", "srgb");
    end
end

end

function values = get_visible_spectrum(data_set)

if ~exist("data_set")
    data_set = "cie1931";
end

if data_set == "cie1931"
    data = csvread("../data/CIE_xyz_1931_2deg.csv");
elseif data_set == "cie1964"
    data = csvread("../data/CIE_xyz_1964_10deg.csv");
end
values = data(:,2:4);


for i = 1:1:length(values)
    RGB = XYZ_to_RGB(values(i,1),values(i,2), values(i,3), "srgb", "D65", "srgb");
    values(i,4:6) = RGB;
end

% experimental: add whitepoint
% [Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);
% values(end+1, :) = [Xw, Yw,Zw,255,255,255];
end