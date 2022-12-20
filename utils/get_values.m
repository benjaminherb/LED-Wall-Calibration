function values = get_values(type, colorspace, steps, peak_luminance)
% returns X,Y,Z,R,G,B (standard sRGB for visualisation)

if ~exist("peak_luminance","var")
    peak_luminance = 1;
end

switch type
    case {"visible_spectrum", "cie1931", "1931"}
        values = get_visible_spectrum("cie1931");
        return;
    case {"cie1964", "1964"}
        values = get_visible_spectrum("cie1964");
        return;
    case  "hue"
        values = get_linear_hue();
        return;
end

i = 1;
for r = 0:1/steps:1
    for g = 0:1/steps:1
        for b = 0:1/steps:1
            
            switch type
                case "borders"
                    valid_value = ((r == 0 || r == 1) && g == b) || ...
                        ((g == 0 || g == 1) && r == b) || ...
                        ((b == 0 || b == 1) && r == g) || ...
                        ((r == 0 || r == 1) && (g == 0 || g == 1)) || ...
                        ((r == 0 || r == 1) && (b == 0 || b == 1)) || ...
                        ((b == 0 || b == 1) && (g == 0 || g == 1));
                    
                case "primary-borders"
                    valid_value = ...
                        ((g == 0) && (b == 0)) ||  ...
                        ((r == 0) && (b == 0)) ||  ...
                        ((g == 0) && (r == 0)) || ...
                        ((r == 1) && (g == b)) || ...
                        ((g == 1) && (r == b)) || ...
                        ((b == 1) && (r == g));
                    
                case "mesh"
                    valid_value = (r == 0 || r == 1 || g == 0 || g == 1 || b == 0 || b == 1);
                    
                otherwise
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
    switch colorspace
        case "srgb"
            values(i,1:3) = RGB_to_XYZ(values(i,4),values(i,5), values(i,6), "srgb", "D65", "srgb");
        case "rec2020"
            values(i,1:3) = RGB_to_XYZ(values(i,4),values(i,5), values(i,6), "rec2020", "D65", "pq", 1);
    end
    values(i,1:3) = values(i,1:3) .* peak_luminance;
end
end


function values = get_linear_hue()
data = readtable("../data/constant_hue_coci_data_hung_berns_1995/table_04.csv");
values = [data.X, data.Y, data.Z];
for i = 1:1:length(values)
    RGB = XYZ_to_RGB(values(i,1),values(i,2), values(i,3), "srgb", "D65", "srgb");
    
    switch string(data.ColorName(i))
        case "Red"
            RGB = [255, 0,0];
        case "Red-yellow"
            RGB = [255, 127,0];
        case "Yellow"
            RGB = [255, 255,0];
        case "Yellow-green"
            RGB = [127, 255,0];
        case "Green"
            RGB = [0, 255,0];
        case "Green-cyan"
            RGB = [0, 255,127];
        case "Cyan"
            RGB = [0, 255,255];
        case "Cyan-blue"
            RGB = [0, 127,255];
        case "Blue"
            RGB = [0, 0,255];
        case "Blue-magenta"
            RGB = [128, 0,255];
        case "Magenta"
            RGB = [255, 0,255];
        case "Magenta-red"
            RGB = [255, 0,128];
    end
    values(i,4:6) = [ ...
        linear_to_sRGB(RGB(1)/255), ...
        linear_to_sRGB(RGB(2)/255), ...
        linear_to_sRGB(RGB(3)/255)];
   
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