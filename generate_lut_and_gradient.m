%% DATA

% Pixel per LED Panel: 128
% Testwall: 384x256
% BIGWall: 768x768 (x2)

%% INPUT

GAMMA = 1;
OUTPUT_DIR = "./out";

WIDTH = 384;
HEIGHT = 256;
PAD_WIDTH = 1920;
PAD_HEIGHT = 1080;
STEP_WIDTHS = [2, 4, 8, 16, 32, 64, 128];

%% PREPERATION

GAMMA_STR = strrep(string(GAMMA), '.', '');
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
eight_bit_gamma = eight_bit_lin .^ GAMMA;

%% GENERATE LUT FILES

for n = 1:15
    scaled_vector = (eight_bit_gamma .* 2^n) + 2^n;
    scaled_vector = uint16(scaled_vector);
    output_file = fopen(LUT_DIR + "LUT_" + scaled_vector(1) + "_" + scaled_vector(256) + "_GAMMA_" + GAMMA_STR +  ".gamdat", 'w');
    fprintf(output_file,GAMMA_STR + '*0#255#0#65535#');
    
    first_number = 0; % Avoid the comma at the eof
    for v = scaled_vector
        if(first_number == 0)
            fprintf(output_file, string(v));
            first_number = 1;
        end
        fprintf(output_file, "," + v);

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
        value = (1/step_count) * step;
        img(:, step*step_width:(step+1)*step_width) = value;
    end
    output_image = GRAD_DIR + "GRADIENT_" + step_width + "_" + WIDTH + "_" + HEIGHT + ".jpg";
    img = padarray(img, [PAD_HEIGHT, PAD_WIDTH], 0, 'post');
    imwrite(img, output_image);   
end


