function img_out = custom_resize(img, max_height)
    [h, ~, ~] = size(img);
    if h > max_height
        scale = max_height / h;
        img_out = imresize(img, scale);
    else
        img_out = img;
    end
end