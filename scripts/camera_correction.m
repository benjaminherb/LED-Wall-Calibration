close all;
clear;
clc;

addpath("../utils/");

captured_testpattern = im2double(raw2rgb("../data/images/20230207/testchart_lumix.RW2", "ColorSpace", "camera"));
%captured_testpattern = im2double(raw2rgb("../data/images/20230207/testchart_sony.ARW", "ColorSpace", "camera"));
original_testpattern = im2double(imread("../data/images/20230124/testchart_original.png"));

captured_landscape = im2double(raw2rgb("../data/images/20230207/landscape_lumix.RW2", "ColorSpace", "camera"));
%captured_landscape = im2double(raw2rgb("../data/images/20230207/landscape_sony.ARW", "ColorSpace", "camera"));
original_landscape = im2double(imread("../data/images/20230124/landscape_original.png"));

% Crop image to roughly the LED wall (draw rectangle -> right click -> crop)
figure('name','Crop image to roughly the LED wall (draw rectangle -> right click -> crop)');
captured_testpattern = imresize(imcrop(captured_testpattern), 0.2);
captured_landscape = imresize(imcrop(captured_landscape), 0.2);
close;

% Check image linearity (not in git due to size)
% evaluate_linearity("../data/images/20230207/blendenreihe_lumix", 'RW2');
% evaluate_linearity("../data/images/20230124/blendenreihe_sony", 'ARW');

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
corrected_landscape = apply_matrix(captured_landscape, calibration_matrix);

%% Compare results

% Convert to sRGB for viewing
captured_testpattern_srgb = img_lin_to_srgb(captured_testpattern);
corrected_testpattern_srgb = img_lin_to_srgb(corrected_testpattern);
captured_landscape_srgb = img_lin_to_srgb(captured_landscape);
corrected_landscape_srgb = img_lin_to_srgb(corrected_landscape);

compare_captured_corrected_original_patches( ...
    get_patches_from_test_image(captured_testpattern_srgb), ... 
    get_patches_from_test_image(corrected_testpattern_srgb), ... 
    get_patches_from_test_image(original_testpattern), ...
    6);

corrected_testpattern_srgb_scaled = corrected_testpattern_srgb ./ max(reshape(corrected_testpattern_srgb,1,[]));
corrected_landscape_srgb_scaled = corrected_landscape_srgb ./ max(reshape(corrected_landscape_srgb,1,[]));

figure('name', 'Comparison: Captured - Corrected - Scaled - Original');
tl = tiledlayout(2,4);
tl.TileSpacing = 'compact';

nexttile();
imshow(captured_testpattern_srgb);
nexttile();
imshow(corrected_testpattern_srgb);
nexttile();
imshow(corrected_testpattern_srgb_scaled);
nexttile();
imshow(original_testpattern);

nexttile();
imshow(captured_landscape_srgb);
nexttile();
imshow(corrected_landscape_srgb);
nexttile();
imshow(corrected_landscape_srgb_scaled);
nexttile();
imshow(original_landscape);

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

function compare_captured_corrected_original_patches(patch_captured, patch_corrected, patch_original, comparison_amount)

patch_names = fieldnames(patch_captured);

if (~exist("comparison_amount", "var") || comparison_amount > length(patch_names))
    comparison_amount = length(patch_names);
end

figure('name', 'Comparison: Captured - Corrected - Original');
tiledlayout(comparison_amount, 3);

for i = 1:comparison_amount
    disp("Captured  " + patch_names{i} + ": " + num2str(get_mean_rgb_from_patch(patch_captured.(patch_names{i})), '%.4f '));
    disp("Corrected " + patch_names{i} + ": " + num2str(get_mean_rgb_from_patch(patch_corrected.(patch_names{i})), '%.4f '));
    disp("Original  " + patch_names{i} + ": " + num2str(get_mean_rgb_from_patch(patch_original.(patch_names{i})), '%.4f '));
    fprintf('\n')
    
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
            % v = max(min(1,v),0);
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
height = height - mod(height,4);
width = width - mod(width,6);
img = img(1:height,1:width,:);

if ~exist("radius", "var")
    radius = round(height/10);
end

patch = img( (height/4) * (2*y-1) - radius : (height/4) * (2*y-1) + radius, ...
    ( width/6) * (2*x-1) - radius : ( width/6) * (2*x-1) + radius, :);

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
