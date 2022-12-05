function test_conversions()
test_XYZ_to_xyY();

end


function result = test_XYZ_to_xyY()
disp("Testing XYZ_to_xyY")
[X,Y,Z] = XYZ_to_xyY(0.9504, 1.0000, 1.0888); % CIE D65 Values
result = [X,Y,Z];
expected = [0.3127, 0.3290, 1.0000];
disp(result)
disp(expected)
assert(isequal(result, expected));
end

