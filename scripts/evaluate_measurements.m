conf.data_dir ="../measurements/response_curve/";
conf.names = ["grey", "red", "green", "blue"];
addpath("../utils");

files = dir(conf.data_dir + "/*.json")';
data = struct();
for i = 1:1:length(files)
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data.(conf.names(i)) = jsondecode(json_text);
end

% plot_Lab(data)
plot_Luv(data)


function plot_Luv(data)
reference_lum = data.grey(end).Yxy.Y;

wLuv = get_Luv(data.grey, reference_lum);
rLuv = get_Luv(data.red, reference_lum);
gLuv = get_Luv(data.green, reference_lum);
bLuv = get_Luv(data.blue, reference_lum);

hold on
plotChromaticity("ColorSpace","uv","View",3,"BrightnessThreshold",0.2/reference_lum)
scatter3(wLuv(:,2), wLuv(:,3), wLuv(:, 1), 'black');
scatter3(rLuv(:,2), rLuv(:,3), rLuv(:, 1), 'black');
scatter3(gLuv(:,2), gLuv(:,3), gLuv(:, 1), 'black');
scatter3(bLuv(:,2), bLuv(:,3), bLuv(:, 1), 'black');
%xlabel("L");
%ylabel("u'");
%zlabel("v'");
grid on
hold off
end


function r = get_Luv(data, reference_lum)

r = NaN(length(data), 3);

for i = 1:1:256
    Y = data(i).Yuv.Y / reference_lum;
    u = data(i).Yuv.u;
    v = data(i).Yuv.v;
    
    if data(i).Yxy.value == "-0008"
        Y = 0; u=0; v=0;
    end
    r(i,:) = [Y,u,v];
end
end



function plot_Lab(data)
reference_lum = data.grey(end).Yxy.Y;

wLab = get_Lab(data.grey, reference_lum);
rLab = get_Lab(data.red, reference_lum);
gLab = get_Lab(data.green, reference_lum);
bLab = get_Lab(data.blue, reference_lum);

hold on
scatter3(wLab(:,1), wLab(:,2), wLab(:, 3), 'black');
scatter3(rLab(:,1), rLab(:,2), rLab(:, 3), 'red');
scatter3(gLab(:,1), gLab(:,2), gLab(:, 3), 'green');
scatter3(bLab(:,1), bLab(:,2), bLab(:, 3), 'blue');
xlabel("L*");
ylabel("a*");
zlabel("b*");
grid on
hold off
end


function r = get_Lab(data, reference_lum)

r = NaN(length(data), 3);

for i = 1:1:256
    X = data(i).XYZ.X / reference_lum;
    Y = data(i).XYZ.Y / reference_lum;
    Z = data(i).XYZ.Z / reference_lum;
    
    if data(i).Yxy.value == "-0008"
        X = 0; Y=0; Z=0;
    end
    r(i,:) = xyz2lab([X,Y,Z], "WhitePoint", "D65");
end
end