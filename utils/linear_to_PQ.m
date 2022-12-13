function E = linear_to_PQ(Fd, max_value)

if ~exist("max_value", "var")
    max_value = 10000;
end
% https://en.wikipedia.org/wiki/Perceptual_quantizer
m1 = 1305/8192;
m2 = 2523/32;
c1 = 107/128;
c2 = 2413/128;
c3 = 2392/128;

Y = Fd/ max_value;
E = ((c1+c2*Y^m1)/(1+c3*Y^m1))^m2;

end