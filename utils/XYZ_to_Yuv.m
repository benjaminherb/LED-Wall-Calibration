function [Y,u,v] = XYZ_to_Yuv(X,Y,Z)
% https://en.wikipedia.org/wiki/CIELUV
if X+Y+Z == 0
    u=0; v=0;
    return;
end
u = (4*X) / (X + 15*Y + 3*Z); % u'
v = (9*Y) / (X + 15*Y + 3*Z); % v'
end