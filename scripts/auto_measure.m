%% USER CONFIG

conf.port = "/dev/ttyACM0"; % used to connect to spectrometer (serialportlist)
conf.command = "all"; % Options: "XYZ", "Yxy", "Yuv", "spectral", "all"
conf.values = 0:1:255;
conf.values = cat(3, zeros(1,256),zeros(1,256), 0:1:255);
% conf.values = [cat(3,255,0,0), cat(3,0,255,0), cat(3,0,0,255)];
% conf.values = ["RED", "GREEN", "BLUE"];
conf.values = get_black_to_white_test_values();


conf.show_images = false; % show the values as an fullscreen image
conf.width = 1920;
conf.height = 1080;
conf.file_name = "measurement_pc_response_curve_grey"; % appended to filename
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

disp(3);
pause(1);
disp(2);
pause(1);
disp(1);
pause(1);
disp(0);
tic
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
        % pause;
    end
    
    current_measurement = spectro.measure(conf.command);
    current_measurement.measurement = conf.values(:,i,:);
    measurements(i) = current_measurement;
    
    while toc - (i*(24*0.02*5)) < 0
        pause(0.01);
    end
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

%% HELPER FUNCTIONS

function values = get_black_to_white_test_values()
values = NaN(1,0,3);
for i=0:255/16:255; values = [values, cat(3,i,0,0)]; end
for i=0:255/16:255; values = [values, cat(3,1,i,i)]; end
for i=0:255/16:255; values = [values, cat(3,0,i,0)]; end
for i=0:255/16:255; values = [values, cat(3,i,1,i)]; end
for i=0:255/16:255; values = [values, cat(3,0,0,i)]; end
for i=0:255/16:255; values = [values, cat(3,i,i,1)]; end
for i=0:255/16:255; values = [values, cat(3,i,i,i)]; end
end