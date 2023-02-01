close all;
clear;
clc;

addpath("../utils/");

captured_testpattern = imread("../data/testchart_blur2.JPG");
original_testpattern = imread("../output/PRIMARIES/PRIMARIES_CAMERA_TEST_384_256.png");

%% Get values and calculate matrix

captured_testpattern = im2double(captured_testpattern);

patch_captured.red   = get_patch_from_test_image(captured_testpattern,1,1);
patch_captured.green = get_patch_from_test_image(captured_testpattern,2,1);
patch_captured.blue  = get_patch_from_test_image(captured_testpattern,3,1);
patch_captured.black = get_patch_from_test_image(captured_testpattern,1,2);
patch_captured.grey  = get_patch_from_test_image(captured_testpattern,2,2);
patch_captured.white = get_patch_from_test_image(captured_testpattern,3,2);

red_captured   = get_lin_mean_rgb_from_patch(patch_captured.red);
green_captured = get_lin_mean_rgb_from_patch(patch_captured.green);
blue_captured  = get_lin_mean_rgb_from_patch(patch_captured.blue);
white_captured = get_lin_mean_rgb_from_patch(patch_captured.white);

calibration_matrix = calculate_calibration_matrix( ...
    red_captured, green_captured, blue_captured, white_captured);

disp("Calibration Matrix");
disp(calibration_matrix);

%% Apply matrix to the image

corrected_testpattern = zeros(size(captured_testpattern));

for y=1:height(captured_testpattern)
    for x=1:width(captured_testpattern)
        
        rgb = [sRGB_to_linear(captured_testpattern(y,x,1)), ...
            sRGB_to_linear(captured_testpattern(y,x,2)), ...
            sRGB_to_linear(captured_testpattern(y,x,3))];
        
        rgb = rgb * calibration_matrix;
        rgb = clip_values(rgb);
        
        corrected_testpattern(y,x,:) = cat(3, linear_to_sRGB(rgb(1)), ...
            linear_to_sRGB(rgb(2)), ...
            linear_to_sRGB(rgb(3)));
    end
end

patch_corrected.red   = get_patch_from_test_image(corrected_testpattern,1,1);
patch_corrected.green = get_patch_from_test_image(corrected_testpattern,2,1);
patch_corrected.blue  = get_patch_from_test_image(corrected_testpattern,3,1);
patch_corrected.black = get_patch_from_test_image(corrected_testpattern,1,2);
patch_corrected.grey  = get_patch_from_test_image(corrected_testpattern,2,2);
patch_corrected.white = get_patch_from_test_image(corrected_testpattern,3,2);

%% Compare results

compare_captured_corrected(patch_captured, patch_corrected , 3)

figure();
tiledlayout(2,1);
nexttile();
imshow(captured_testpattern);
nexttile();
imshow(corrected_testpattern);

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

function patch = get_patch_from_test_image(img, x, y, radius)

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
