function img = pad_image_to_size(input_img, h_out, w_out,  pad_value)

    [h_in, w_in, ~] = size(input_img);
    pad_h = floor((h_out - h_in) / 2);
    pad_h_off = mod(h_out - h_in, 2);
    pad_w = floor((w_out - w_in) / 2);
    pad_w_off = mod(w_out - w_in, 2);

    img = padarray(input_img, [pad_h, pad_w], pad_value);
    img = padarray(img, [pad_h_off, pad_w_off], pad_value, 'post');

end