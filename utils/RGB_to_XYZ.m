function XYZ = RGB_to_XYZ(R, G, B, cs, wp, tc)

if wp == "D65"
    [Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);
end

if cs == "srgb"
    % https://en.wikipedia.org/wiki/SRGB
    [Xr, Yr, Zr] = xyY_to_XYZ(0.6400, 0.3300, 0.2126);
    [Xg, Yg, Zg] = xyY_to_XYZ(0.3000, 0.6000, 0.7152);
    [Xb, Yb, Zb] = xyY_to_XYZ(0.1500, 0.0600, 0.0722);
end

if tc == "srgb"
    RGB = [sRGB_to_linear(R), sRGB_to_linear(G), sRGB_to_linear(B)];
elseif tc == "linear"
    RGB = [R,G,B];
end

RGB_to_XYZ_matrix = get_RGB_to_XYZ_matrix(Xr, Yr, Zr, Xg, Yg, Zg, Xb, Yb, Zb, Xw, Yw, Zw);

XYZ = RGB * RGB_to_XYZ_matrix;

