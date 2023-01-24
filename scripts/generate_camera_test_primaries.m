%% Testbilder Primaries

%% INFO

% PX/Panel:  128x128
% Test Wall: 384x256
% LED Wall:  768x768 (x2)

%% User Input

WIDTH = 384;
HEIGHT = 256;
PAD_WIDTH = 1920;
PAD_HEIGHT = 1080;
OUTPUT_DIR = "../output";
COLOR_IMAGE = imread("../data/Lanscape_test.png");

%% Generate Primaries

PAD_WIDTH = PAD_WIDTH - WIDTH;
PAD_HEIGHT = PAD_HEIGHT - HEIGHT;
PRIMARIES_DIR = OUTPUT_DIR + "/PRIMARIES/";

if not(isfolder(PRIMARIES_DIR))
    mkdir(PRIMARIES_DIR)
end

colors = ["Rot", "Grün", "Blau"];
img = zeros(HEIGHT, WIDTH, 3);

for c=1:3
    disp("Generating Color patch " + colors(c));

    img(1:HEIGHT/2, ((WIDTH/3)*(c-1))+1:((WIDTH/3)*c), c) = 1;
    img((HEIGHT/2)+1:end, ((WIDTH/3)*(c-1))+1:((WIDTH/3)*c), :) = 0.5*(c-1);
end

output_image = PRIMARIES_DIR + "PRIMARIES_CAMERA_TEST_" + WIDTH + "_" + HEIGHT + ".png";
img = padarray(img, [PAD_HEIGHT, PAD_WIDTH], 0, 'post');
imwrite(img, output_image);

fig = figure('Name', 'TEST', 'MenuBar', 'none', ...
    'WindowState', 'fullscreen', 'ToolBar', 'none');
set(gca, 'Position', [0 0 1 1]);
imshow(img);