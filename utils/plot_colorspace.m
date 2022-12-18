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
    elseif colormodel == "PQuv"
        [~,v2,v3] = XYZ_to_Yuv(values(i,1), values(i,2), values(i,3));
        v1 = linear_to_PQ(values(i,1));
    elseif colormodel == "Yuv"
        [v1,v2,v3] = XYZ_to_Yuv(values(i,1), values(i,2), values(i,3));
        
    end
    values_converted(i,1:3) = [v1,v2,v3];
end

if plot_type == "scatter"
    scatter3(values_converted(:,2), values_converted(:,3), values_converted(:, 1), 50, values(:,4:6), '.');
elseif plot_type == "trisurf"
    [TriIdx, ~] = convhull(values_converted(:,2), values_converted(:,3), values_converted(:, 1));
    vol = trisurf(TriIdx, values_converted(:,2), values_converted(:,3), values_converted(:, 1), 'EdgeColor', 'none', 'FaceColor', 'interp');
    vol.FaceVertexCData = values(:,4:6);
elseif plot_type == "projection-boundary"
    boundary_indices = convhull(values_converted(:,2), values_converted(:,3));
    boundary_values = NaN(length(boundary_indices), 6);
    for i = 1:1:length(boundary_indices)
        boundary_values(i,:) = [values_converted(boundary_indices(i),2), values_converted(boundary_indices(i),3), 0, values(i,4:6)];
    end
    hold on
    steps = 10;
    luminance_step = 1 / steps;
    for i = 0:1:steps
        plot3(boundary_values(:,1),boundary_values(:,2),repmat(i*luminance_step, length(boundary_values), 1), "black");
    end
    %scatter3(boundary_values(:,1),boundary_values(:,2),ones(length(boundary_values), 1), 50, 'black', '.');
elseif plot_type == "hue-curves"
    for i = 1:1:length(values)/9     
        plot3(values_converted((i-1)*9+1:i*9,2), ...
              values_converted((i-1)*9+1:i*9,3), ...
              values_converted((i-1)*9+1:i*9,1), ...
              'Color', values(i*9,4:6));
    end
    
end
if colormodel == "luv"
    xlabel("v*");
    ylabel("u*");
    zlabel("L*");
elseif colormodel == "lab"
    xlabel("a*");
    ylabel("b*");
    zlabel("L*");
elseif colormodel == "PQuv"
    xlabel("u'");
    ylabel("v'");
    zlabel("PQ");
elseif colormodel == "Yuv"
    xlabel("u'");
    ylabel("v'");
    zlabel("Y");
end

end