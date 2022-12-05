function [L,U,V] = XYZ_to_LUV(X,Y,Z, Xw,Yw,Zw)
% https://en.wikipedia.org/wiki/CIELUV

% kappa = 903.3; % Theoretical correct value: 24389/27
% epsilon = 0.008856; % Theoretical correct value: 216/24389
% yr = Y / Yw;
% L = (116 * yr^(1/3) - 16) * (yr > epsilon) + (kappa * yr) * (yr <= epsilon);

L = (29/3)^3 * Y/Yw *(Y / Yw <= (6/29)^3) ...
    + 116 * (Y/Yw)^(1/3) - 16 * (Y/Yw > (6/29)^3); % L*


u = (4*X) / (X + 15*Y + 3*Z); % u'
v = (9*Y) / (X + 15*Y + 3*Z); % v'

uw = (4*Xw) / (Xw + 15*Yw + 3*Zw); % u'w
vw = (9*Yw) / (Xw + 15*Yw + 3*Zw); % v'w

U = 13 * L * (u-uw); % u*
V = 13 * L * (v-vw); % v*

end