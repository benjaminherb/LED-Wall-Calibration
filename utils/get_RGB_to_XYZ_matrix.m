function matrix = get_RGB_to_XYZ_matrix(Xr, Yr, Zr, Xg, Yg, Zg, Xb, Yb, Zb, Xw, Yw, Zw)
%% calcRGB2XYZMatrix according to Formulas from:
% http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

XYZrgbMatrix = [Xr Xg Xb; ...
                Yr Yg Yb; ...
                Zr Zg Zb];

XwYwZwVec = [Xw; Yw; Zw];
            
SrSgSbVec = XYZrgbMatrix \ XwYwZwVec;

matrix = XYZrgbMatrix .* [SrSgSbVec'; SrSgSbVec'; SrSgSbVec'];
 
end
