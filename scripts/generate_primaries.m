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

%% Generate Primaries

PAD_WIDTH = PAD_WIDTH - WIDTH;
PAD_HEIGHT = PAD_HEIGHT - HEIGHT;
PRIMARIES_DIR = OUTPUT_DIR + "/PRIMARIES/";

if not(isfolder(PRIMARIES_DIR))
    mkdir(PRIMARIES_DIR)
end

colors = ["Rot", "Grün", "Blau"];

for c=1:3
    disp("Generating Color " + colors(c));

    img = zeros(HEIGHT, WIDTH, 3);
    img(:, :,c) = 1;

    output_image = PRIMARIES_DIR + "PRIMARIES_" + colors(c) + "_" + WIDTH + "_" + HEIGHT + ".jpg";
    img = padarray(img, [PAD_HEIGHT, PAD_WIDTH], 0, 'post');
    imwrite(img, output_image);
end


