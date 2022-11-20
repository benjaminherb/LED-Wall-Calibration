%% WIE FARBEN REPRÄSENTIEREN? [1,0,0], cat(3,1,0,0), cell array {[1 0 0], ...} ...

% CONFIG
HEIGHT = 1080;
WIDTH = 1920;
OUTPUT_DIR = "../measurements/";
PORT = "/dev/ttyACM0"; % check with 'serialportlist'
NAME = "CURVE";  % appended to the folder name

GAMMA = 2.2;
% GREY VALUES
VALUES = 0:8:255;

% PRIMARIES
% VALUES = [cat(3,255,0,0), cat(3,0,255,0), cat(3,0,0,255)];


%% PREP
addpath("../utils/")

MES_DIR = OUTPUT_DIR + "auto_measure/" +  datestr(datetime,'yyyymmdd_HHMMss_' + NAME);
if not(isfolder(MES_DIR))
    mkdir(MES_DIR)
end

%% MEASUREMENT

fig = figure('Name', 'TEST', 'MenuBar', 'none', 'WindowState', 'fullscreen', 'ToolBar', 'none');
img_txt = imread('../res/user_info.png');
img_txt = im2double(img_txt .* 255);
img = pad_image_to_size(img_txt, HEIGHT, WIDTH, 1);
img = cat(3, img,img,img); % create RGB image for more versitility
set(gca, 'Position', [0 0 1 1]);
imshow(img);

spectro = Spectrometer(PORT);
spectro.enter_remote_mode()

imshow(img);
pause;

output_file = fopen(MES_DIR + 'MEASUREMENT.csv', 'w');
fprintf(output_file, 'VALUE,X,Y,Z\n\r');
measurements = NaN(3, length(VALUES));
    
for i = 1:length(VALUES)
    
    img = repmat(VALUES(:,i,:) ./ 255, HEIGHT, WIDTH);
    imshow(img);
    result = spectro.command("M2");
    result = strsplit(result,',');
    X = str2num(result(3));
    Y = str2num(result(4));
    Z = str2num(result(5));    
    measurements(i,:) = [X Y Z];
    fprintf(output_file, string(VALUES(:,i,1)) + ',' + string(X) + ',' + string(Y) + ',' + string(Z) + ','  + '\n\r');

end

spectro.quit_remote_mode();
clear("spectro");

%% EVALUATION
fig = figure('Name', 'Gamma Curve compared to measured response curve');

% MEASURED RESPONSE CURVE
plot(VALUES ./ 255, measurements(:,2) ./ measurements(end,2), 'black'); % labels used for color
hold on
% REFERENCE GAMMA CURVE
plot(VALUES ./255, (VALUES ./255) .^ GAMMA, 'red');


