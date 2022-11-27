%% USER CONFIG

conf.port = "/dev/ttyACM0"; % used to connect to spectrometer (serialportlist)
conf.command = "all"; % Options: "XYZ", "Yxy", "Yuv", "spectral", "all"
conf.values = 0:1:255;
conf.values = cat(3, zeros(1,256),zeros(1,256), 0:1:255);
% conf.values = [cat(3,255,0,0), cat(3,0,255,0), cat(3,0,0,255)];
% conf.values = ["RED", "GREEN", "BLUE"];

conf.show_images = true; % show the values as an fullscreen image
conf.width = 1920;
conf.height = 1080;
conf.file_name = "measurement_pc_response_curve_blue"; % appended to filename
conf.output_dir = "../measurements/auto_measure/";

%% SETUP

addpath("../utils/")

if not(isfolder(conf.output_dir))
    mkdir(conf.output_dir)
end

% establish connection to spectrometer
clear("spectro");
spectro = Spectrometer(conf.port);
if ~spectro.is_connected()
    return
end

%% MEASUREMENT

if conf.show_images
    % fullscreen figure
    fig = figure('Name', 'TEST', 'MenuBar', 'none', ...
        'WindowState', 'fullscreen', 'ToolBar', 'none');
    img_txt = imread('../res/user_info.png');
    img_txt = im2double(img_txt .* 255);
    img = pad_image_to_size(img_txt, conf.height, conf.width, 1);
    set(gca, 'Position', [0 0 1 1]);
    imshow(img);
    pause;
end

clear("measurements")

pause(10);
for i = 1:length(conf.values)
    
    if conf.show_images
        img = repmat(conf.values(:,i,:) ./ 255, conf.height, conf.width);
        imshow(img);
        try
            fprintf("\nStarting measurement (" + string(conf.values(:,i,:)) + ")\n");
        catch exception % workaround pls fix
            fprintf("\nStarting measurement (" + i +")\n");
        end
    else
        try
            fprintf("\nStart next measurement (" + string(conf.values(:,i,:)) + ")?\n");
        catch exception
            fprintf("\nStarting measurement (" + i +")\n");
        end
        pause;
    end
    
    current_measurement = spectro.measure(conf.command);
    current_measurement.measurement = conf.values(:,i,:);
    measurements(i) = current_measurement;
end

if conf.show_images
    close(fig);
end

%% END
output_file = fopen( ...
    conf.output_dir + datestr(datetime,'yyyymmdd_HHMMss') + "_" ...
    + conf.file_name + ".json", 'w');


fprintf(output_file, jsonencode(measurements, 'PrettyPrint', true));

% spectro.quit_remote_mode();
clear("spectro");