function y = linear_to_sRGB(x)
% LINEAR_TO_SRGB Converts value from linear to sRGB
y = (x>0.0031308).*(1.055.*x.^(1/2.4)-0.055) + (x<=0.0031308).*12.92.*x;
end

