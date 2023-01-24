
addpath("../utils/");

TEST_IMG = imread("../data/testchart_blur2.JPG");

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

lin_red_patch = getlinvalue(red_patch);
lin_green_patch = getlinvalue(green_patch);
lin_blue_patch = getlinvalue(blue_patch);
lin_white_patch = getlinvalue(white_patch);
mean(lin_red_patch(:,:,1), 'all')
mean(lin_green_patch(:,:,2), 'all')
mean(lin_blue_patch(:,:,3), 'all')
mean(lin_white_patch(:,:,1), 'all')
mean(lin_white_patch(:,:,2), 'all')
mean(lin_white_patch(:,:,3), 'all')
mean(lin_white_patch(:,:,:), 'all')


%%

function lin_rgb = getlinvalue(img)

lin_rgb = NaN(size(img));

img = double(img);

for x=1:length(img)
    for y=1:length(img)
        for c=1:3
            lin_rgb(x,y,c) =img(x,y,c)./255; %%<<sRGB_to_linear(img(x,y,c)./255);
        end
    end
end
end
