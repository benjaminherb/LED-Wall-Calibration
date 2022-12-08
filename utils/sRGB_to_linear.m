function y = sRGB_to_linear(x)
% SRGB_TO_LINEAR Converts value from sRGB to linear
y = (x>0.04045)*((x+0.055)/1.055)^2.4 + (x<=0.04045)*(x/12.92);
end

