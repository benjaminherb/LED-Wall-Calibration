function result = convert_measurements(measurements, whitepoint, target)

result = NaN(length(measurements), 6);
for i = 1:1:length(measurements)
    
    if measurements(i).Yxy.value == "-0008" % in accurate readings
        result(i,1:3) = [0,0,0];
    elseif target == "Yxy"
        result(i,1:3) = [measurements(i).Yxy.Y, measurements(i).Yxy.x, measurements(i).Yxy.y];
    elseif target == "xyY"
        result(i,1:3) = [measurements(i).Yxy.x, measurements(i).Yxy.y, measurements(i).Yxy.Y];
    elseif target == "XYZ"
        result(i,1:3) = [measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z];
    elseif target == "luv" || target == "cieluv"
        [L,u,v] = XYZ_to_LUV( ...
            measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z, ...
            whitepoint.XYZ.X, whitepoint.XYZ.Y, whitepoint.XYZ.Z);
        result(i,1:3) = [L,u,v];
    elseif target == "lab" || target == "cielab"
        [L,a,b] = XYZ_to_LAB( ...
            measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z, ...
            whitepoint.XYZ.X, whitepoint.XYZ.Y, whitepoint.XYZ.Z);
        result(i,1:3) = [L,a,b];
    end
      % convert grey values to RGB tripplets
    if length(measurements(i).measurement) == 1
        measurements(i).measurement = [measurements(i).measurement,measurements(i).measurement,measurements(i).measurement];
    end
    result(i,4:6) = measurements(i).measurement;
end