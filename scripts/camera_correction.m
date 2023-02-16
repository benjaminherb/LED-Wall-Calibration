close all;
clear;
clc;

%% User Config
addpath("../utils/");

% used for the corrected images
conf.output_dir = "../output/precorrected_images/";
conf.height = 1080;
conf.width = 1920;

captured_testpattern = im2double(raw2rgb("../data/images/20230214/testpattern_captured.ARW", "ColorSpace", "camera"));
%captured_testpattern = im2double(raw2rgb("../data/images/20230207/testchart_sony.ARW", "ColorSpace", "camera"));
original_testpattern = im2double(imread("../data/images/20230124/testchart_original.png"));

captured_landscape = im2double(raw2rgb("../data/images/20230214/landscape_02_captured.ARW", "ColorSpace", "camera"));
%captured_landscape = im2double(raw2rgb("../data/images/20230207/landscape_sony.ARW", "ColorSpace", "camera"));
original_landscape = im2double(imread('../data/images/20230214/landscape_02.png'));

%%

% Crop image to roughly the LED wall (draw rectangle -> right click -> crop)
figure('name','Crop image to roughly the LED wall (draw rectangle -> right click -> crop)');
[captured_testpattern, crop_rectangle] = imcrop(captured_testpattern);
% use the same crop on both images assuming the camera position did not
% change
captured_landscape = imcrop(captured_landscape, crop_rectangle);
close;

% Check image linearity (not in git due to size constraints)
% evaluate_linearity("../data/images/20230207/blendenreihe_lumix", 'RW2');
% evaluate_linearity("../data/images/20230124/blendenreihe_sony", 'ARW');

%% Get values and calculate matrix

patches_captured = get_patches_from_test_image(captured_testpattern);

red_captured   = get_median_rgb_from_patch(patches_captured.red);
green_captured = get_median_rgb_from_patch(patches_captured.green);
blue_captured  = get_median_rgb_from_patch(patches_captured.blue);
white_captured = get_median_rgb_from_patch(patches_captured.white);

calibration_matrix = calculate_calibration_matrix( ...  
    red_captured, green_captured, blue_captured, white_captured);

disp("Calibration Matrix");
disp(calibration_matrix);

%% Apply matrix to the image

corrected_testpattern = apply_matrix(captured_testpattern, calibration_matrix);
corrected_landscape = apply_matrix(captured_landscape, calibration_matrix);

%% Compare results

% convert to srgb for viewing
captured_testpattern_srgb= linear_to_sRGB(captured_testpattern);
corrected_testpattern_srgb = linear_to_sRGB(corrected_testpattern);
corrected_testpattern_srgb_scaled = corrected_testpattern_srgb ./ max(reshape(corrected_testpattern_srgb,1,[]));

captured_landscape_srgb = linear_to_sRGB(captured_landscape);
corrected_landscape_srgb = linear_to_sRGB(corrected_landscape);
corrected_landscape_srgb_scaled = corrected_landscape_srgb ./ max(reshape(corrected_landscape_srgb,1,[]));

compare_patches( ...
    get_patches_from_test_image(captured_testpattern_srgb), ... 
    get_patches_from_test_image(corrected_testpattern_srgb), ... 
    get_patches_from_test_image(corrected_testpattern_srgb_scaled), ... 
    get_patches_from_test_image(original_testpattern), ...
    6);

compare_images(...
    captured_testpattern_srgb, corrected_testpattern_srgb, ...
    corrected_testpattern_srgb_scaled, original_testpattern, ...
    captured_landscape_srgb, corrected_landscape_srgb, ...
    corrected_landscape_srgb_scaled, original_landscape)

%% Create and save (pre-)corrected image

if not(isfolder(conf.output_dir))
    mkdir(conf.output_dir)
end

original_landscape_precorrected = linear_to_sRGB(apply_matrix(sRGB_to_linear(original_landscape), calibration_matrix));

imwrite(padarray(original_landscape_precorrected, ...
    [conf.height-height(original_landscape_precorrected), ...
    conf.width-width(original_landscape_precorrected)], 0, 'post'), ...
    conf.output_dir + "landscape_precorrected.png");

%% Compare Results (precorrected images captured with the same camera)

original_landscape_2 = im2double(imread('../data/images/20230214/landscape_02.png'));

captured_landscape_uncorrected   = im2double(raw2rgb("../data/images/20230214/landscape_02_captured.ARW", "ColorSpace", "camera"));
captured_landscape_precorrected  = im2double(raw2rgb("../data/images/20230214/landscape_02_captured_precorrected.ARW", "ColorSpace", "camera"));

if ~exist("crop_rectangle", "var") % use the existing crop if it was defined before
    figure('name', 'Crop');
    [captured_landscape_uncorrected_srgb, crop_rectangle] = imcrop(linear_to_sRGB(captured_landscape_uncorrected));
else
    captured_landscape_uncorrected_srgb = imcrop(linear_to_sRGB(captured_landscape_uncorrected), crop_rectangle);
end
captured_landscape_precorrected_srgb = imcrop(linear_to_sRGB(captured_landscape_precorrected), crop_rectangle);

figure('name', 'Result comparison (with precorrection)');
tl = tiledlayout(1,3);
tl.TileSpacing = 'compact';

% Match the brightness to evaluate the color differences
black_level_offset = 0.045;
brightness_scaling = 0.55;

nexttile();
imshow(captured_landscape_uncorrected_srgb ./ brightness_scaling + black_level_offset);
title("LED-Wall (Scaled + Black Offset)");
nexttile();
imshow(captured_landscape_precorrected_srgb ./ brightness_scaling + black_level_offset);
title("LED-Wall (Pre-)corrected (Scaled + Black Offset)");
nexttile();
imshow(imgaussfilt(original_landscape_2, 7));
title("Original Image (+ Gaussian Blur)");

%% Utility Functions

% https://docs.unrealengine.com/4.27/en-US/WorkingWithMedia/IntegratingMedia/InCameraVFX/InCameraVFXCameraCalibration/
function matrix = calculate_calibration_matrix(red, green, blue, white)
f = [red; green; blue];
white_scaled = white ./ max(white);
S = f^(-1) * white_scaled';
f = f * [S(1), 0, 0; ...
         0, S(2), 0; ...
         0, 0, S(3)];
matrix = f^(-1);
matrix = transpose(matrix);
end


function img = apply_matrix(img, matrix, clip)

if ~exist("clip", "var")
    clip = true;
end

image_vector = reshape(img, [], 3) * matrix;
if clip
    image_vector(1:end) = max(0, min(1, image_vector(1:end)));
end
img = reshape(image_vector, size(img));
end


function patches = get_patches_from_test_image(img)
% extract patches from a testpattern and save them in a struct

patches.red   = get_patch(img,1,1);
patches.green = get_patch(img,2,1);
patches.blue  = get_patch(img,3,1);
patches.black = get_patch(img,1,2);
patches.grey  = get_patch(img,2,2);
patches.white = get_patch(img,3,2);

end


function patch = get_patch(img, x, y, radius)
% extract patches from the know positions

% normalize HxW to be devisable by 2 and 3
[height,width, ~] = size(img);
height = height - mod(height,4);
width = width - mod(width,6);
img = img(1:height,1:width,:);

if ~exist("radius", "var")
    radius = round(height/10);
end

patch = img( (height/4) * (2*y-1) - radius : (height/4) * (2*y-1) + radius, ...
    ( width/6) * (2*x-1) - radius : ( width/6) * (2*x-1) + radius, :);

end


function rgb = get_median_rgb_from_patch(img, sRGB)
if ~exist("sRGB", "var")
    sRGB = false;
end

lin_rgb = NaN(size(img));
img = double(img);

for x=1:length(img)
    for y=1:length(img)
        for c=1:3
            if sRGB
                lin_rgb(x,y,c) = sRGB_to_linear(img(x,y,c));  
            else
                lin_rgb(x,y,c) = img(x,y,c);
            end
        end
    end
end
rgb = [median(lin_rgb(:,:,1), 'all'), median(lin_rgb(:,:,2), 'all'), median(lin_rgb(:,:,3), 'all')];
end


function compare_patches(patch_captured, patch_corrected, patch_corrected_scaled, patch_original, comparison_amount)

patch_names = fieldnames(patch_captured);

if (~exist("comparison_amount", "var") || comparison_amount > length(patch_names))
    comparison_amount = length(patch_names);
end

figure('name', 'Comparison: Captured - Corrected - Corrected (Scaled) -  Original');
tiledlayout(comparison_amount, 4);

for i = 1:comparison_amount
    disp("Captured  " + patch_names{i} + ": " + num2str(get_median_rgb_from_patch(patch_captured.(patch_names{i})), '%.4f '));
    disp("Corrected " + patch_names{i} + ": " + num2str(get_median_rgb_from_patch(patch_corrected.(patch_names{i})), '%.4f '));
    disp("Scaled    " + patch_names{i} + ": " + num2str(get_median_rgb_from_patch(patch_corrected_scaled.(patch_names{i})), '%.4f '));
    disp("Original  " + patch_names{i} + ": " + num2str(get_median_rgb_from_patch(patch_original.(patch_names{i})), '%.4f '));
    fprintf('\n')
    
    nexttile();
    imshow(patch_captured.(patch_names{i}));
    if i == 1
        title("Captured");
    end
    
    nexttile();
    imshow(patch_corrected.(patch_names{i}));
    if i == 1
        title("Corrected");
    end
    
    nexttile();
    imshow(patch_corrected_scaled.(patch_names{i}));
    if i == 1
        title("Corrected & Scaled");
    end
    
    nexttile();
    imshow(patch_original.(patch_names{i}));
    if i == 1
        title("Original");
    end
end

end


function compare_images( ...
    captured_testpattern_srgb, corrected_testpattern_srgb, ...
    corrected_testpattern_srgb_scaled, original_testpattern, ...
    captured_landscape_srgb, corrected_landscape_srgb, ...
    corrected_landscape_srgb_scaled, original_landscape)
                
figure('name', 'Comparison: Captured - Corrected - Corrected(Scaled) - Original');
tl = tiledlayout(2,4);
tl.TileSpacing = 'compact';

nexttile();
imshow(captured_testpattern_srgb);
title("Captured");
nexttile();
imshow(corrected_testpattern_srgb);
title("Corrected");
nexttile();
imshow(corrected_testpattern_srgb_scaled);
title("Corrected & Scaled");
nexttile();
imshow(original_testpattern);
title("Original");

nexttile();
imshow(captured_landscape_srgb);
nexttile();
imshow(corrected_landscape_srgb);
nexttile();
imshow(corrected_landscape_srgb_scaled);
nexttile();
imshow(original_landscape);
end


function evaluate_linearity(path, file_extension)
disp("Blendenreihe");
files = dir(path + "/*."+ file_extension)';
data = struct();
values = zeros(length(files),1);

for i = 1:1:length(files)
    img = raw2rgb(files(i).folder + "/" + files(i).name, 'ColorSpace', 'camera');
    grey_patch = get_patch(img, 2,2);
    disp(files(i).name + ": " + ( mean(reshape(grey_patch,1,[])) ));
    values(i) = mean(reshape(grey_patch,1,[]));
end

values = round(sort(values));
for i = 1:length(values)
    disp(values(i) / (2^14));
    %disp(values(i));
end
clear("i", "img", "grey_patch");
end
