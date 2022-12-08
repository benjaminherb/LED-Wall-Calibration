function RGB = XYZ_to_RGB(X, Y, Z, colorspace, whitepoint, transfercurve)

if whitepoint == "D65"
    [Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);
end

if colorspace == "srgb"
    % https://en.wikipedia.org/wiki/SRGB
    [Xr, Yr, Zr] = xyY_to_XYZ(0.6400, 0.3300, 0.2126);
    [Xg, Yg, Zg] = xyY_to_XYZ(0.3000, 0.6000, 0.7152);
    [Xb, Yb, Zb] = xyY_to_XYZ(0.1500, 0.0600, 0.0722);
end
XYZ = [X,Y,Z];

XYZ_to_RGB_matrix = get_RGB_to_XYZ_matrix(Xr, Yr, Zr, Xg, Yg, Zg, Xb, Yb, Zb, Xw, Yw, Zw) ^-1;

RGB = XYZ * XYZ_to_RGB_matrix';


if transfercurve == "srgb"
    RGB = [linear_to_sRGB(RGB(1)), linear_to_sRGB(RGB(2)), linear_to_sRGB(RGB(3))];
end