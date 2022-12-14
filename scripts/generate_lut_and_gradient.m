%% INFO

% PX/Panel:  128x128
% Test Wall: 384x256
% LED Wall:  768x768 (x2)

addpath("../utils/");

%% INPUT

transfer_curve = "pqinverse";      % pq, sRGB oder gamma
GAMMA = 2.2;
OUTPUT_DIR = "../output";

WIDTH = 1920;
HEIGHT = 1080;

% Pad is used if the gradient needs to be included in a bigger frame
% (mostly for the test panel)
% set to the same as the WIDTH/HEIGHT if not needed
PAD_WIDTH = 1920;
PAD_HEIGHT = 1080;

STEP_WIDTHS = [1,2, 4, 8, 16, 32, 64, 128];

%% PREPARATION

GAMMA_STR = string(GAMMA*10); % used for filenames/start of gamdat file
PAD_WIDTH = PAD_WIDTH - WIDTH;
PAD_HEIGHT = PAD_HEIGHT - HEIGHT;
LUT_DIR = OUTPUT_DIR + "/LUTS/";
GRAD_DIR = OUTPUT_DIR + "/GRADIENTS/";

if not(isfolder(LUT_DIR))
    mkdir(LUT_DIR)
end

if not(isfolder(GRAD_DIR))
    mkdir(GRAD_DIR)
end

%% BASE VECTOR

eight_bit_lin = (0:1:255)./255;
eight_bit_curve = NaN(size(eight_bit_lin));

switch(transfer_curve)
    case "pqinverse"
        for i = 1:1:length(eight_bit_lin)
            eight_bit_curve(i) = PQ_to_linear(eight_bit_lin(i), 1);
        end
        fileprefix = "LUT_PQ_";
     case "pq"
        for i = 1:1:length(eight_bit_lin)
            eight_bit_curve(i) = linear_to_PQ(eight_bit_lin(i), 1);
        end
        fileprefix = "LUT_PQ_";
    case "srgb"
        for i = 1:1:length(eight_bit_lin)
            eight_bit_curve(i) = linear_to_sRGB(eight_bit_lin(i));
        end
        fileprefix = "LUT_sRGB_";
    case "gamma"
        eight_bit_curve = eight_bit_lin .^ GAMMA;
        fileprefix = "LUT_GAMMA_" + GAMMA_STR + "_";
    otherwise
        error("Unkknown transfercurve: " + transfer_curve);
end
%% GENERATE LUT FILES
timestamp = datestr(datetime,'yyyymmdd_HHMMss');

LUT_DIR = LUT_DIR + "/" + timestamp + "/";
if not(isfolder(LUT_DIR))
    mkdir(LUT_DIR)
end

for n = 1:15
    scaled_vector = (eight_bit_curve .* 2^n) + 2^n;
    scaled_vector = uint16(scaled_vector);

    output_file = fopen(LUT_DIR + fileprefix + scaled_vector(1) + "_" + scaled_vector(256)  +  ".gamdat", 'w');
    fprintf(output_file, GAMMA_STR + '*0#255#0#65535#');

    first_number = 1; % Avoid the comma at the eof
    for v = scaled_vector
        if(first_number)
            fprintf(output_file, string(v));
            first_number = 0;
        else
        fprintf(output_file, "," + v);
        end
        
    end
end


%% GENEREATE GRADIENT

if not(isfolder(OUTPUT_DIR + "/GRADIENTS"))
    mkdir(OUTPUT_DIR + "/GRADIENTS")
end

for step_width = STEP_WIDTHS
    step_count = floor(WIDTH / step_width);
    img = zeros(HEIGHT, WIDTH);
    for step = 1:step_count-1
        % value = (1/step_count) * step;
        value = step/255;
        img(:, step*step_width:(step+1)*step_width) = value;
    end
    output_image = GRAD_DIR + "GRADIENT_"  + WIDTH + "_" + HEIGHT + "_" + step_width + ".png";
    img = padarray(img, [PAD_HEIGHT, PAD_WIDTH], 0, 'post');
    imwrite(img, output_image);
end


