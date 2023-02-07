close all;
clear;
clc;

addpath("../utils/");

%captured_testpattern = im2double(imread("../data/images/20230124/testchart_blur_2.jpg"));
captured_testpattern = im2double(imread("../data/images/charts/testchart_camera_big_wall.tiff"));
original_testpattern = im2double(imread("../data/images/20230124/testchart_original.png"));

%captured_testimage   = im2double(imread("../data/images/20230124/landscape_blur.jpg"));
captured_testimage   = im2double(imread("../data/images/charts/landscape_camera_big_wall.tiff"));
original_testimage   = im2double(imread("../data/images/20230124/landscape_original.png"));

w = width(captured_testpattern);
h = height(captured_testpattern);

max_captured_testpattern = max(reshape(captured_testpattern,1,[]));
max_captured_testimage = max(reshape(captured_testimage,1,[]));
captured_testpattern = imresize(captured_testpattern, 0.5);
captured_testimage = imresize(captured_testimage, 0.5);

%captured_testpattern = img_srgb_to_lin(captured_testpattern);
%captured_testimage = img_srgb_to_lin(captured_testimage);

% Check image linearity
% show_theoretical_linear_values_and_stuff();
% evaluate_linearity("../data/images/20230124/blendenreihe_raw");
%%
%imshow(img_vlog_to_lin(captured_testpattern))
%% Get values and calculate matrix

patches_captured = get_patches_from_test_image(captured_testpattern);

red_captured   = get_mean_rgb_from_patch(patches_captured.red);
green_captured = get_mean_rgb_from_patch(patches_captured.green);
blue_captured  = get_mean_rgb_from_patch(patches_captured.blue);
white_captured = get_mean_rgb_from_patch(patches_captured.white);

calibration_matrix = calculate_calibration_matrix( ...  
    red_captured, green_captured, blue_captured, white_captured);

disp("Calibration Matrix");
disp(calibration_matrix);

%% Apply matrix to the image
corrected_testpattern = apply_matrix(captured_testpattern, calibration_matrix);
corrected_testimage = apply_matrix(captured_testimage, calibration_matrix);

%% Compare results
% Back to srgbe

corrected_testpattern = img_lin_to_srgb(corrected_testpattern);
original_testpattern = img_lin_to_srgb(original_testpattern);

%corrected_testimage = img_lin_to_srgb(corrected_testimage);

%%
max_value = max(reshape(corrected_testpattern,1,[]));
corrected_testpattern_scaled = corrected_testpattern ./ max_value;

patches_corrected_scaled = get_patches_from_test_image(corrected_testpattern_scaled);
patches_corrected = get_patches_from_test_image(corrected_testpattern);
patches_original = get_patches_from_test_image(original_testpattern);


compare_captured_corrected_original(patches_captured, patches_corrected, patches_original, 6);

figure();
tl = tiledlayout(2,4);
tl.TileSpacing = 'compact';

nexttile();
imshow(captured_testpattern);
nexttile();
imshow(corrected_testpattern);
nexttile();
imshow(corrected_testpattern_scaled);
nexttile();
imshow(original_testpattern);
%%
corrected_testimage_scaled = corrected_testimage ./ max(reshape(corrected_testpattern,1,[]));


nexttile();
imshow(captured_testimage);
nexttile();
imshow(corrected_testimage);
nexttile();
imshow(corrected_testimage_scaled);
nexttile();
imshow(original_testimage);


%% Utility Functions

function corrected_image = apply_matrix(original_image, matrix)
corrected_image = zeros(size(original_image));

for y=1:height(original_image)
    for x=1:width(original_image)
        
        rgb = [original_image(y,x,1), ...
               original_image(y,x,2), ...
               original_image(y,x,3)];
        
        rgb = rgb * matrix;
        rgb = clip_values(rgb);
        
        corrected_image(y,x,:) = cat(3, ...
            rgb(1), ...
            rgb(2), ...
            rgb(3));
    end
end

end


function compare_captured_corrected_original(patch_captured, patch_corrected, patch_original, comparison_amount)

patch_names = fieldnames(patch_captured);

if (~exist("comparison_amount", "var") || comparison_amount > length(patch_names))
    comparison_amount = length(patch_names);
end

figure();
tiledlayout(comparison_amount, 3);

for i = 1:comparison_amount
    disp("Captured " + patch_names{i});
    disp(get_mean_rgb_from_patch(patch_captured.(patch_names{i})));
    disp("Corrected " + patch_names{i});
    disp(get_mean_rgb_from_patch(patch_corrected.(patch_names{i})));
    %disp("Original " + patch_names{i});
    %disp(get_mean_rgb_from_patch(patch_original.(patch_names{i})));
    
    nexttile();
    imshow(patch_captured.(patch_names{i}));
    nexttile();
    imshow(patch_corrected.(patch_names{i}));
    nexttile();
    imshow(patch_original.(patch_names{i}));
end

end

function srgb = img_lin_to_srgb(lin)
srgb = NaN(size(lin));
for y=1:height(lin)
    for x=1:width(lin)
        for c=1:3
            srgb(y,x,c) = linear_to_sRGB(lin(y,x,c));
        end
    end
end
end

function lin = img_srgb_to_lin(srgb)
lin = NaN(size(srgb));
for y=1:height(srgb)
    for x=1:width(srgb)
        for c=1:3
            lin(y,x,c) = linear_to_sRGB(srgb(y,x,c));
        end
    end
end
end


function lin = img_vlog_to_lin(srgb)
lin = NaN(size(srgb));
for y=1:height(srgb)
    for x=1:width(srgb)
        for c=1:3
            v = srgb(y,x,c);
            %v = max(min(1,v),0);
            lin(y,x,c) = ((v-0.125) / 5.6) * (v<0.181) + ...
                         (10.0^((v-0.598206)/0.241514) - 0.00873) * (v >= 0.181);       
        end
    end
end
end

function rgb = get_mean_rgb_from_patch(img, sRGB)
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
width = width - mod(width,6);
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

function show_theoretical_linear_values_and_stuff()
for i = 0:12
    disp(round((1/(2^i)) * 255));
end

disp("sRGB");
for i = 0:12
    disp(round(linear_to_sRGB(1/(2^i)) * 255));
end

disp("PQ");
for i = 0:24
    disp(round(linear_to_PQ(1/(2^i)*10000) * 255));
end
end

function evaluate_linearity(path)
disp("Blendenreihe (linearisiert über sRGB)");
files = dir(path + "/*.tiff")';
data = struct();
values = zeros(length(files),1);

for i = 1:1:length(files)
    img = imread(files(i).folder + "/" + files(i).name);
    grey_patch = get_patch(img, 2,2);
    disp(files(i).name + ": " + ( mean(reshape(grey_patch,1,[])) ));
    values(i) = mean(reshape(grey_patch,1,[]));
end

values = round(sort(values));
clear("i", "img", "grey_patch");
end
