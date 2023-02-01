close all;
clear;
clc;

addpath("../utils/");

captured_testpattern = imread("../data/testchart_blur2.JPG");
original_testpattern = imread("../output/PRIMARIES/PRIMARIES_CAMERA_TEST_384_256.png");
captured_testimage   = imread("../data/landscape_camera.JPG");
original_testimage   = imread("../data/lanscape_test.png");

%% Get values and calculate matrix

captured_testpattern = im2double(captured_testpattern);
captured_testimage = im2double(captured_testimage);

patches_captured = get_patches_from_test_image(captured_testpattern);

red_captured   = get_lin_mean_rgb_from_patch(patches_captured.red);
green_captured = get_lin_mean_rgb_from_patch(patches_captured.green);
blue_captured  = get_lin_mean_rgb_from_patch(patches_captured.blue);
white_captured = get_lin_mean_rgb_from_patch(patches_captured.white);

calibration_matrix = calculate_calibration_matrix( ...
    red_captured, green_captured, blue_captured, white_captured);

disp("Calibration Matrix");
disp(calibration_matrix);

%% Apply matrix to the image
corrected_testpattern = apply_matrix(captured_testpattern, calibration_matrix);
corrected_testimage = apply_matrix(captured_testimage, calibration_matrix);

%% Compare results
patches_corrected = get_patches_from_test_image(corrected_testpattern);
patches_original = get_patches_from_test_image(original_testpattern);

% compare_captured_corrected(patches_captured, patches_corrected, 3)

figure();
tl = tiledlayout(2,4);
tl.TileSpacing = 'compact';

nexttile();
imshow(captured_testpattern);
nexttile();
imshow(corrected_testpattern);
nexttile();
imshow(corrected_testpattern ./ 0.9400);
nexttile();
imshow(original_testpattern);


nexttile();
imshow(captured_testimage);
nexttile();
imshow(corrected_testimage);
nexttile();
imshow(corrected_testimage ./ 0.9400);
nexttile();
imshow(original_testimage);


%% Utility Functions

function corrected_image = apply_matrix(original_image, matrix)
corrected_image = zeros(size(original_image));

for y=1:height(original_image)
    for x=1:width(original_image)
        
        rgb = [sRGB_to_linear(original_image(y,x,1)), ...
               sRGB_to_linear(original_image(y,x,2)), ...
               sRGB_to_linear(original_image(y,x,3))];
        
        rgb = rgb * matrix;
        rgb = clip_values(rgb);
        
        corrected_image(y,x,:) = cat(3, linear_to_sRGB(rgb(1)), ...
                                        linear_to_sRGB(rgb(2)), ...
                                        linear_to_sRGB(rgb(3)));
    end
end

end


function compare_captured_corrected(patch_captured, patch_corrected, comparison_amount)

patch_names = fieldnames(patch_captured);

if (~exist("comparison_amount", "var") || comparison_amount > length(patch_names))
    comparison_amount = length(patch_names);
end

figure();
tiledlayout(comparison_amount,2);

for i = 1:comparison_amount
    disp("Captured " + patch_names{i});
    disp(get_lin_mean_rgb_from_patch(patch_captured.(patch_names{i})));
    disp("Corrected " + patch_names{i});
    disp(get_lin_mean_rgb_from_patch(patch_corrected.(patch_names{i})));

    nexttile();
    imshow(patch_captured.(patch_names{i}));
    nexttile();
    imshow(patch_corrected.(patch_names{i}));
end

end


function rgb = get_lin_mean_rgb_from_patch(img)
lin_rgb = NaN(size(img));
img = double(img);

for x=1:length(img)
    for y=1:length(img)
        for c=1:3
            lin_rgb(x,y,c) =sRGB_to_linear(img(x,y,c));
        end
    end
end
rgb = [mean(lin_rgb(:,:,1), 'all'), mean(lin_rgb(:,:,2), 'all'), mean(lin_rgb(:,:,3), 'all')];
end


function patches = get_patches_from_test_image(img)

patches.red   = get_patch(img,1,1);
patches.green = get_patch(img,2,1);
patches.blue  = get_patch(img,3,1);
patches.black = get_patch(img,1,2);
patches.grey  = get_patch(img,2,2);
patches.white = get_patch(img,3,2);

end


function patch = get_patch(img, x, y, radius)

% normalize HxW to be devisable by 2 and 3
[height,width, ~] = size(img);
height = height - mod(height,2);
width = width - mod(width,3);
img = img(1:height,1:width,:);

if ~exist("radius", "var")
    radius = round(height/10);
end

patch = img( (height/4) * (2*y-1) - radius : (height/4) * (2*y-1) + radius, ...
             ( width/6) * (2*x-1) - radius : ( width/6) * (2*x-1) + radius, :);

end


function matrix = calculate_calibration_matrix(red, green, blue, white)
f = [red; green; blue];
white_scaled = white ./ max(white);
S = f^(-1) * white_scaled';
f = f * [S(1), 0, 0; ...
         0, S(2), 0; ...
         0, 0, S(3)];
matrix = f^(-1);
end


function rgb = clip_values(rgb)
% clamp values between 0 and 1
rgb = [max(min(1,rgb(1)),0), ...
       max(min(1,rgb(2)),0), ...
       max(min(1,rgb(3)),0)];
end
