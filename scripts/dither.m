% myVals = uint16( PQ2L( linspace(0,L2PQ(1350),2^8) )' / 1350 * 65535 );
% sprintf('%i,',myVals)

width  = 1920;
height = 1080;
output_dir = "../out/dither/";

% create output folder if it does not exist yet
if not(isfolder(output_dir))
    mkdir(output_dir)
end

eineZeile = 0:1/8:width/8;
eineZeile = eineZeile(1:end-1); % to match resolution
bild = repmat(eineZeile, height,1);
bildOhneDither = uint8(floor(bild));
 
bildMitDitherNormal = uint8( bild + randn(size(bild)) );
bildMitDitherGleich = uint8( bild + rand(size(bild)) );
bildMitDitherFloydSteinberg = uint8( floyd_steinberg_dithering(double(bildOhneDither), bild) );

mean(bildMitDitherFloydSteinberg)
 
imwrite(bildOhneDither, output_dir + 'ohneDither.png')
imwrite(bildMitDitherNormal, output_dir + 'bildMitDitherNormal.png')
imwrite(bildMitDitherGleich, output_dir + 'bildMitDitherGleich.png')
imwrite(bildMitDitherFloydSteinberg, output_dir + 'bildMitDitherFloydSteinberg.png')


function image_dithered = floyd_steinberg_dithering(image_quantized, image_reference)
% https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering

[height, width, ~] = size(image_quantized);
image_dithered = image_reference;

for y = 1:height - 1
    for x = 2:width - 1
        old_pixel = image_dithered(y, x, :);
        new_pixel = round(image_dithered(y, x, :));
        
        image_dithered(y, x, :) = new_pixel;
        
        error = old_pixel - new_pixel;
        
        image_dithered(y    , x + 1, :) = image_dithered(y    , x + 1, :) + error .* 7 / 16;
        image_dithered(y + 1, x - 1, :) = image_dithered(y + 1, x - 1, :) + error .* 3 / 16;
        image_dithered(y + 1, x    , :) = image_dithered(y + 1, x    , :) + error .* 5 / 16;
        image_dithered(y + 1, x + 1, :) = image_dithered(y + 1, x + 1, :) + error .* 1 / 16;
        
    end
end
end