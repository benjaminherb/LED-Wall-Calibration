function [X, Y, Z] = xyY_to_XYZ(x,y,Y)
% http://brucelindbloom.com/index.html?Eqn_xyY_to_XYZ.html

if y == 0
    X=0;Y=0;Z=0;
else
    X = (x*Y)/y;
    Z = ((1-x-y)*Y)/y;
end

end