conf.data_dir ="../measurements/response_curve/";
conf.names = ["grey", "red", "green", "blue"];
addpath("../utils");

files = dir(conf.data_dir + "/*.json")';
data = struct();
for i = 1:1:length(files)
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data.(conf.names(i)) = jsondecode(json_text);
end

figure("Name", "Response Curve Comparison in CIELUV and CIELAB", "NumberTitle", "off", "Position", [0 0 1200 500] );
tiledlayout(1,2);

nexttile()
plot_Lab(data)
nexttile()
plot_Luv(data)

 
function plot_Luv(data)
reference_white = data.grey(end).XYZ;

wLuv = get_Luv(data.grey, reference_white);
rLuv = get_Luv(data.red, reference_white);
gLuv = get_Luv(data.green, reference_white);
bLuv = get_Luv(data.blue, reference_white);

hold on
scatter3(wLuv(:,2), wLuv(:,3), wLuv(:, 1), 50, wLuv(:,4:6) ./255);
scatter3(rLuv(:,2), rLuv(:,3), rLuv(:, 1), 50,rLuv(:,4:6)./255);
scatter3(gLuv(:,2), gLuv(:,3), gLuv(:, 1), 50,gLuv(:,4:6)./255);
scatter3(bLuv(:,2), bLuv(:,3), bLuv(:, 1), 50,bLuv(:,4:6)./255);
%plotChromaticity("ColorSpace","uv","View",3,"BrightnessThreshold",0)

xlabel("u*");
ylabel("v*");
zlabel("L*");
grid on
hold off

title("CIELUV");
end


function r = get_Luv(data, refWP)

r = NaN(length(data), 6);

for i = 1:1:256
 
    % GET L*u*v*
    [L, u, v] = XYZ_to_CIELUV(data(i).XYZ.X, data(i).XYZ.Y, data(i).XYZ.Z, ...
                              refWP.X,refWP.Z,refWP.Z);
    
    %u = data(i).Yuv.u; % u' w/o WP compensation
    %v = data(i).Yuv.v; % v' w/o WP compensation
    name = data(i).measurement;
    if length(name) == 1 % grey value
        name = [name, name, name];
    else
        name = name';
    end
    if data(i).Yxy.value == "-0008"
        L = 0; u=0; v=0; name=[0,0,0];
    end
    r(i,:) = [L,u,v, name];
end
end



function plot_Lab(data)
reference_white = data.grey(end).XYZ;

wLab = get_Lab(data.grey, reference_white);
rLab = get_Lab(data.red, reference_white);
gLab = get_Lab(data.green, reference_white);
bLab = get_Lab(data.blue, reference_white);

hold on
scatter3(wLab(:,2), wLab(:,3), wLab(:,1), 50, wLab(:,4:6)./255);
scatter3(rLab(:,2), rLab(:,3), rLab(:,1), 50, rLab(:,4:6)./255);
scatter3(gLab(:,2), gLab(:,3), gLab(:,1), 50, gLab(:,4:6)./255);
scatter3(bLab(:,2), bLab(:,3), bLab(:,1), 50, bLab(:,4:6)./255);
xlabel("a*");
ylabel("b*");
zlabel("L*");
grid on
hold off
title("CIELAB");
end


function r = get_Lab(data, refWP)

r = NaN(length(data), 6);

for i = 1:1:256
    X = data(i).XYZ.X;
    Y = data(i).XYZ.Y;
    Z = data(i).XYZ.Z;
    
    name = data(i).measurement;
    if length(name) == 1 % grey value
        name = [name, name, name];
    else
        name = name';
    end
    
    [L, a, b] = XYZ_to_CIELAB(X, Y, Z, refWP.X, refWP.Y, refWP.Z); 
    
    if data(i).Yxy.value == "-0008"
        L=0; a=0; b=0; name=[0,0,0];
    end
    r(i,:) = [L, a, b, name];
end
end
