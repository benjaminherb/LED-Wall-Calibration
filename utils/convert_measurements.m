function result = convert_measurements(measurements, whitepoint, target, peak_luminance)
if ~exist("peak_luminance", "var")
    peak_luminance = 10000;
end

result = NaN(length(measurements), 6);
for i = 1:1:length(measurements)
    
    
    if target == "xyY"
        result(i,1:3) = [measurements(i).Yxy.x, measurements(i).Yxy.y, measurements(i).Yxy.Y];
        if measurements(i).XYZ.X + measurements(i).XYZ.Y + measurements(i).XYZ.Z == 0 ...
            || measurements(i).Yxy.value == "-0008"
            result(i, 1:3) = [whitepoint.Yxy.x, whitepoint.Yxy.y, measurements(i).Yxy.Y];
        end
        
    elseif target == "XYZ"
        result(i,1:3) = [measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z];
        if measurements(i).Yxy.value == "-0008" % in accurate readings
            result(i,1:3) = [0,0,0];
        end
        
    elseif target == "luv" || target == "cieluv"
        [L,u,v] = XYZ_to_LUV( ...
            measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z, ...
            whitepoint.XYZ.X, whitepoint.XYZ.Y, whitepoint.XYZ.Z);
        result(i,1:3) = [L,u,v];
        if measurements(i).Yxy.value == "-0008" % in accurate readings
            result(i,1:3) = [0,0,0];
        end
        
    elseif target == "lab" || target == "cielab"
        [L,a,b] = XYZ_to_LAB( ...
            measurements(i).XYZ.X, measurements(i).XYZ.Y, measurements(i).XYZ.Z, ...
            whitepoint.XYZ.X, whitepoint.XYZ.Y, whitepoint.XYZ.Z);
        result(i,1:3) = [L,a,b];
        if measurements(i).Yxy.value == "-0008" % in accurate readings
            result(i,1:3) = [0,0,0];
        end
        
    elseif target == "PQuv" || target == "PQu'v'"
        PQ = linear_to_PQ(measurements(i).Yuv.Y, peak_luminance);
        result(i, 1:3) = [PQ, measurements(i).Yuv.u, measurements(i).Yuv.v];
        if (measurements(i).XYZ.X + measurements(i).XYZ.Y + measurements(i).XYZ.Z == 0 ...
            || measurements(i).Yxy.value == "-0008")
            result(i, 1:3) = [PQ, whitepoint.Yuv.u, whitepoint.Yuv.v];
        end
    end
    
    % convert grey values to RGB tripplets
    if length(measurements(i).measurement) == 1
        measurements(i).measurement = [measurements(i).measurement, ...
                                       measurements(i).measurement, ...
                                       measurements(i).measurement];
    end
    result(i,4:6) = measurements(i).measurement ./ 255;
end