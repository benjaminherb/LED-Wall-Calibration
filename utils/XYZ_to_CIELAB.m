function [L, a, b] = XYZ_to_CIELAB(X, Y, Z, Xw, Yw, Zw)

kappa = 24389/27; % Actual CIE standard: 903.3
epsilon = 216/24389; % Actual CIE standard: 0.008856

xr = X / Xw;
yr = Y / Yw;
zr = Z / Zw;

fx = (xr)^(1/3) * (xr > epsilon) + ((kappa * xr + 16) / 116) * (xr <= epsilon);
fy = (yr)^(1/3) * (yr > epsilon) + ((kappa * yr + 16) / 116) * (yr <= epsilon);
fz = (zr)^(1/3) * (zr > epsilon) + ((kappa * zr + 16) / 116) * (zr <= epsilon);

L = 116 * fy - 16;
a = 500 * (fx - fy);
b = 200 * (fy - fz);

end