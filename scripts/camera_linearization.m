
addpath("../utils/");

TEST_IMG = imread("../data/testchart_blur2.JPG");
ORIGINAL_IMG =  imread("../output/PRIMARIES/PRIMARIES_CAMERA_TEST_384_256.png");
%%

TEST_IMG = TEST_IMG(1:2000, 1:3000, :);
[HEIGHT,WIDTH, ~] = size(TEST_IMG);
PATCH_RADIUS = 200;

red_patch = TEST_IMG(HEIGHT/4-PATCH_RADIUS:HEIGHT/4+PATCH_RADIUS, WIDTH/6-PATCH_RADIUS:WIDTH/6+PATCH_RADIUS, :);
green_patch = TEST_IMG(HEIGHT/4-PATCH_RADIUS:HEIGHT/4+PATCH_RADIUS, (WIDTH/6)*3-PATCH_RADIUS:(WIDTH/6)*3+PATCH_RADIUS, :);
blue_patch = TEST_IMG(HEIGHT/4-PATCH_RADIUS:HEIGHT/4+PATCH_RADIUS,(WIDTH/6)*5-PATCH_RADIUS:(WIDTH/6)*5+PATCH_RADIUS, :);


black_patch = TEST_IMG((HEIGHT/4)*3-PATCH_RADIUS:(HEIGHT/4)*3+PATCH_RADIUS, WIDTH/6-PATCH_RADIUS:WIDTH/6+PATCH_RADIUS, :);
grey_patch = TEST_IMG((HEIGHT/4)*3-PATCH_RADIUS:(HEIGHT/4)*3+PATCH_RADIUS, (WIDTH/6)*3-PATCH_RADIUS:(WIDTH/6)*3+PATCH_RADIUS, :);
white_patch = TEST_IMG((HEIGHT/4)*3-PATCH_RADIUS:(HEIGHT/4)*3+PATCH_RADIUS,(WIDTH/6)*5-PATCH_RADIUS:(WIDTH/6)*5+PATCH_RADIUS, :);



tiledlayout(2,3);

nexttile()
imshow(red_patch);
nexttile()
imshow(green_patch);
nexttile()
imshow(blue_patch);
nexttile()
imshow(black_patch);
nexttile()
imshow(grey_patch);
nexttile()
imshow(white_patch);

%%

rgb_red_patch = get_lin_rgb_from_patch(red_patch);
rgb_green_patch = get_lin_rgb_from_patch(green_patch);
rgb_blue_patch = get_lin_rgb_from_patch(blue_patch);
rgb_white_patch = get_lin_rgb_from_patch(white_patch);

%%

rgb_f = [rgb_red_patch; rgb_green_patch; rgb_blue_patch]

rgb_white_scaled = rgb_white_patch./max(rgb_white_patch)

S = rgb_f^(-1)*rgb_white_scaled'

rgb_f = rgb_f * [S(1), 0, 0; 0, S(2), 0; 0, 0, S(3)]

calibration_matrix = rgb_f^(-1)

%%

corrected_img = zeros(size(TEST_IMG));

for x=1:height(TEST_IMG)
    for y=1:width(TEST_IMG)
        rgb = [sRGB_to_linear(double(TEST_IMG(x,y,1))./255), sRGB_to_linear(double(TEST_IMG(x,y,2))./255), sRGB_to_linear(double(TEST_IMG(x,y,3))./255)];
        rgb = rgb'./calibration_matrix;
        rgb_flipped = cat(3,linear_to_sRGB(rgb(1)), linear_to_sRGB(rgb(2)), linear_to_sRGB(rgb(3)));
        corrected_img(x,y,:) = rgb_flipped;
    end
end


imshow(corrected_img);



%%

function rgb = get_lin_rgb_from_patch(img)

lin_rgb = NaN(size(img));

img = double(img);

for x=1:length(img)
    for y=1:length(img)
        for c=1:3
            lin_rgb(x,y,c) =sRGB_to_linear(img(x,y,c)./255);
        end
    end
end

rgb = [mean(lin_rgb(:,:,1), 'all'), mean(lin_rgb(:,:,2), 'all'), mean(lin_rgb(:,:,3), 'all')];

% XYZ= RGB_to_XYZ(rgb(1), rgb(2), rgb(3), "srgb", "D65", "srgb");



end
