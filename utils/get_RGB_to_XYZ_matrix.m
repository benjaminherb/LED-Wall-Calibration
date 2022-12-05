function matrix = get_RGB_to_XYZ_matrix( xr, yr, xg, yg, xb, yb, Xw, Yw, Zw)
%% calcRGB2XYZMatrix according to Formulas from:
% http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

Xr = xr / yr;
Yr = 1;
Zr = (1 - xr - yr)/yr;

Xg = xg / yg;
Yg = 1;
Zg = (1 - xg - yg)/yg;

Xb = xb / yb;
Yb = 1;
Zb = (1 - xb - yb)/yb;

XYZrgbMatrix = [Xr Xg Xb; ...
                Yr Yg Yb; ...
                Zr Zg Zb];

XwYwZwVec = [Xw; Yw; Zw];
            
SrSgSbVec = XYZrgbMatrix \ XwYwZwVec;

matrix = XYZrgbMatrix .* [SrSgSbVec'; SrSgSbVec'; SrSgSbVec'];
 
end
