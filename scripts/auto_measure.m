%% USER CONFIG

conf.port = "/dev/ttyACM0"; % used to connect to spectrometer (serialportlist)
conf.command = "M1";
conf.values = 0:1:255;
% config.values = [cat(3,255,0,0), cat(3,0,255,0), cat(3,0,0,255)];

conf.show_images = true; % show the values as an fullscreen image
conf.width = 1920;
conf.height = 1080;
conf.file_name = "reference_curve"; % appended to filename
conf.output_dir = "../measurements/auto_measure/";

%% SETUP

addpath("../utils/")

if not(isfolder(conf.output_dir))
    mkdir(conf.output_dir)
end

% establish connection to spectrometer
spectro = Spectrometer(conf.port);
if ~spectro.is_connected()
    return
end

% create csv header
value_names = spectro.get_command_values(conf.command);
header = "value";
for v = value_names
    header = header + "," + v;
end

%% MEASUREMENT

if config.show_image
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

output_file = fopen( ...
    conf.output_dir + datestr(datetime,'yyyymmdd_HHMMss') + "_" ...
    + conf.file_name + ".csv", 'w');

measurements = NaN(length(value_names) + 1, length(conf.values));

for i = 1:length(conf.values)
    
    if conf.show_image
        img = repmat(conf.values(:,i,:) ./ 255, conf.height, conf.width);
        imshow(img);
    else
        disp("Start next measurement? Value: " + string(conf.values(:,i,:)));
        pause;
    end
    
    result = spectro.command(conf.command);
    result = strsplit(result,',');
    
    measurements(:,i) = result;
    
    csv_row = string(conf.values(:,i,1));
    for r = result
        csv_row = csv_row + ',' + r;
    end
    csv_row = csv_row + '\n';
    fprintf(output_file, csv_row);
end

if conf.show_image
    fig.close();
end

%% END
% spectro.quit_remote_mode();
clear("spectro");