%% CONFIG
HEIGHT = 1080;
WIDTH = 1920;

VALUES = [0, 12, 110 ,220 ,123, 255];

addpath("../utils/")

% PREP
fig = figure('Name', 'TEST', 'MenuBar', 'none', 'WindowState', 'fullscreen', 'ToolBar', 'none');
img_txt = imread('../res/user_info.png');
img_txt = im2double(img_txt .* 255);
[ty, tx, td] = size(img_txt);


img = pad_image_to_size(img_txt, HEIGHT, WIDTH, 1);
set(gca, 'Position', [0 0 1 1]);

imshow(img);

%% 
pause;
for i = 1:length(VALUES)
    
    img(:) = VALUES(i) ./255;
    imshow(img);
    pause(1);

end

