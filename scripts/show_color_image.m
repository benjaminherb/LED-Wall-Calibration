%% Testbilder Primaries

%% INFO

% PX/Panel:  128x128
% Test Wall: 384x256
% LED Wall:  768x768 (x2)

%% User Input

WIDTH = 1920;
HEIGHT = 1080;
COLOR_IMAGE = imread("../data/lanscape_test.png");

%% Generate Primaries

PAD_WIDTH = PAD_WIDTH - WIDTH;
PAD_HEIGHT = PAD_HEIGHT - HEIGHT;

[COLOR_HEIGHT,COLOR_WIDTH,~] = size(COLOR_IMAGE);

COLOR_IMAGE = double(COLOR_IMAGE)./255.0;

img = zeros(HEIGHT, WIDTH, 3);

img(1:COLOR_HEIGHT,1:COLOR_WIDTH,:) = COLOR_IMAGE;

%img = padarray(img, [PAD_HEIGHT, PAD_WIDTH], 0, 'post');

fig = figure('Name', 'TEST', 'MenuBar', 'none', ...
    'WindowState', 'fullscreen', 'ToolBar', 'none');
set(gca, 'Position', [0 0 1 1]);
imshow(img);