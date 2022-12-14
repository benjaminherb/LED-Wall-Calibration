function Fd = PQ_to_linear(E, max_value)
% Return PQ with 1976 CIE u'v'

if ~exist("max_value", "var")
    max_value = 10000;
end
% https://en.wikipedia.org/wiki/Perceptual_quantizer
m1 = 1305/8192;
m2 = 2523/32;
c1 = 107/128;
c2 = 2413/128;
c3 = 2392/128;

Fd = max_value * (max(E^(1/m2) - c1, 0) / (c2-c3 * E^(1/m2)))^(1/m1);

end