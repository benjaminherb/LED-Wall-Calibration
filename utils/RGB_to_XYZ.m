function XYZ = RGB_to_XYZ(R, G, B, primaries, whitepoint, transfercurve, peak_luminance)

if ~exist("peak_luminance","var")
    peak_luminance = 10000;
end

switch whitepoint
    case "D65"
        [Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);
end

switch primaries
    case {"srgb" , "rec709"}
        % https://en.wikipedia.org/wiki/SRGB
        [Xr, Yr, Zr] = xyY_to_XYZ(0.6400, 0.3300, 0.2126);
        [Xg, Yg, Zg] = xyY_to_XYZ(0.3000, 0.6000, 0.7152);
        [Xb, Yb, Zb] = xyY_to_XYZ(0.1500, 0.0600, 0.0722);
    case "rec2020"
        % https://www.itu.int/dms_pubrec/itu-r/rec/bt/R-REC-BT.2100-2-201807-I!!PDF-E.pdf
        [Xr, Yr, Zr] = xyY_to_XYZ(0.708, 0.292, 1);
        [Xg, Yg, Zg] = xyY_to_XYZ(0.170, 0.797, 1);
        [Xb, Yb, Zb] = xyY_to_XYZ(0.131, 0.046, 1);
        
end

switch transfercurve
    case "srgb"
        RGB = [sRGB_to_linear(R), sRGB_to_linear(G), sRGB_to_linear(B)];
    case "pq"
        RGB = [PQ_to_linear(R, peak_luminance), PQ_to_linear(G, peak_luminance), PQ_to_linear(B, peak_luminance)];
    otherwise
        RGB = [R,G,B];
        
end

RGB_to_XYZ_matrix = get_RGB_to_XYZ_matrix(Xr, Yr, Zr, Xg, Yg, Zg, Xb, Yb, Zb, Xw, Yw, Zw);
XYZ = RGB * RGB_to_XYZ_matrix';

%XYZ = rgb2xyz([R,G,B], "WhitePoint", "D65", "ColorSpace", "srgb" );

