function plot_colorspace(values, colormodel, plot_type, peak_luminance)

if ~exist("peak_luminance", "var")
    peak_luminance = 10000;
end
% values = get_black_to_white_test_values();
% values = get_all_values(); % ALL the values

% D65
[Xw, Yw, Zw] = xyY_to_XYZ(0.3127, 0.3290, 1.0000);

values_converted = zeros(length(values), 3);

for i = 1:1:length(values)
    
    switch colormodel
        case "luv"
            [v1,v2,v3] = XYZ_to_LUV(values(i,1), values(i,2), values(i,3), Xw, Yw, Zw);
            if sum(values(i,1:3)) == 0
                [~,v2,v3] = XYZ_to_LUV(Xw,Yw,Zw);
                v1 = 0;
            end
        case  "lab"
            [v1,v2,v3] = XYZ_to_LAB(values(i,1), values(i,2), values(i,3), Xw, Yw, Zw);
            %if sum(values(i,1:3)) == 0
            %    v1,v2,v3] = [0,0,0];
            %end
        case  "PQuv"
            [~,v2,v3] = XYZ_to_Yuv(values(i,1), values(i,2), values(i,3));
            if sum(values(i,1:3)) == 0 % avoid dividing / 0 -> set black to wp
                [~,v2,v3] = XYZ_to_Yuv(Xw,Yw,Zw);
            end
            v1 = linear_to_PQ(values(i,1), peak_luminance);
        case  "Yuv"
            [v1,v2,v3] = XYZ_to_Yuv(values(i,1), values(i,2), values(i,3));
            
            if sum(values(i,1:3)) == 0
                [~,v2,v3] = XYZ_to_Yuv(Xw,Yw,Zw);
                v1 = 0;
            end
        case "ICtCp"
            [v1,v2,v3] = XYZ_to_ICtCp(values(i,1), values(i,2), values(i,3));
    end
    values_converted(i,1:3) = [v1,v2,v3];
end

switch plot_type
    case "scatter"
        scatter3(values_converted(:,2), values_converted(:,3), values_converted(:, 1), 50, values(:,4:6), '.');
        
    case "trisurf"
        [TriIdx, ~] = convhull(values_converted(:,2), values_converted(:,3), values_converted(:, 1));
        vol = trisurf(TriIdx, values_converted(:,2), values_converted(:,3), values_converted(:, 1), 'EdgeColor', 'none', 'FaceColor', 'interp');
        vol.FaceVertexCData = values(:,4:6);
        
    case  "projection-boundary"
        boundary_indices = convhull(values_converted(:,2), values_converted(:,3));
        boundary_values = NaN(length(boundary_indices), 6);
        for i = 1:1:length(boundary_indices)
            boundary_values(i,:) = [values_converted(boundary_indices(i),2), values_converted(boundary_indices(i),3), 0, values(i,4:6)];
        end
        hold on
        steps = 10;
        luminance_step = 1 / steps;
        for i = 0:1:steps
            plot3(boundary_values(:,1), ...
                  boundary_values(:,2), ...
                  repmat(i*luminance_step, ...
                  length(boundary_values), 1), "black");
        end
        %scatter3(boundary_values(:,1),boundary_values(:,2),ones(length(boundary_values), 1), 50, 'black', '.');
        
    case "hue-curves"
        for i = 1:1:length(values)/9
            plot3(values_converted((i-1)*9+1:i*9,2), ...
                values_converted((i-1)*9+1:i*9,3), ...
                values_converted((i-1)*9+1:i*9,1), ...
                'Color', values(i*9,4:6));
            scatter3(values_converted((i-1)*9+1:i*9,2), ...
                values_converted((i-1)*9+1:i*9,3), ...
                values_converted((i-1)*9+1:i*9,1), ...
                50, values(i*9,4:6), 'o');
        end
        
    case "hue-projection"
        for i = 1:1:length(values)/9
            hue_line(:,1) = values_converted((i-1)*9+1:i*9, 2);
            hue_line(:,2) = values_converted((i-1)*9+1:i*9, 3);
            hue_line(:,3) = values_converted((i-1)*9+1:i*9, 1);
            hue_line = sort_hue_based_on_distance(hue_line);
            
            plot3(hue_line(:,1), hue_line(:,2), zeros(9,1), ...
                'Color', values(i*9,4:6));
            scatter3(hue_line(:,1), hue_line(:,2), zeros(9,1), ...
                50, values(i*9,4:6), 'o');
        end
        
end

switch colormodel
    case "luv"
        xlabel("v*");
        ylabel("u*");
        zlabel("L*");
    case "lab"
        xlabel("a*");
        ylabel("b*");
        zlabel("L*");
    case "PQuv"
        xlabel("u'");
        ylabel("v'");
        zlabel("PQ");
    case "Yuv"
        xlabel("u'");
        ylabel("v'");
        zlabel("Y");
    case "ICtCp"
        xlabel("Ct");
        ylabel("Cp");
        zlabel("I");
end

end

function sorted = sort_hue_based_on_distance(hue_line)
[~, max_index] = max(hue_line(:,3));
max_value_01 = hue_line(max_index, 1);
max_value_02 = hue_line(max_index, 2);
distances = NaN(length(hue_line),1);
for i = 1:1:length(hue_line)
    distances(i) = sqrt((max_value_01-hue_line(i,1))^2 + (max_value_02-hue_line(i,2))^2);
end
[~, ids] = sort(distances);

sorted = hue_line(ids,:);

end