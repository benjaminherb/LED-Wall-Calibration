function plot_colorspace(values, colormodel, plot_type)
% values = get_black_to_white_test_values();
% values = get_all_values(); % ALL the values

% D65
[Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);

values_converted = NaN(length(values), 3);

for i = 1:1:length(values)
      
    if colormodel == "luv"
        [v1,v2,v3] = XYZ_to_LUV(values(i,1), values(i,2), values(i,3), Xw, Yw, Zw);
    elseif colormodel == "lab"
        [v1,v2,v3] = XYZ_to_LAB(values(i,1), values(i,2), values(i,3), Xw, Yw, Zw);
    end
    
    values_converted(i,1:3) = [v1,v2,v3];
end

if plot_type == "scatter"
    scatter3(values_converted(:,2), values_converted(:,3), values_converted(:, 1), 50, values(:,4:6), '.');
elseif plot_type == "trisurf"
    [TriIdx, ~] = convhull(values_converted(:,2), values_converted(:,3), values_converted(:, 1));
    vol = trisurf(TriIdx, values_converted(:,2), values_converted(:,3), values_converted(:, 1), 'EdgeColor', 'none', 'FaceColor', 'interp');
    vol.FaceVertexCData = values(:,4:6);
end
if colormodel == "luv"
    xlabel("v*");
    ylabel("u*");
    zlabel("L*");
elseif colormodel == "lab"
    xlabel("a*");
    ylabel("b*");
    zlabel("L*");
end

end