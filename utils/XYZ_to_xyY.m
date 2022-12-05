function [x,y,Y] = XYZ_to_xyY(X,Y,Z)
% http://brucelindbloom.com/index.html?Eqn_XYZ_to_xyY.html
x = X / (X+Y+Z);
y = Y / (X+Y+Z);
end
