clear
clc

img = imread('Final/assets/uv_1.jpg');

img = custom_resize(img, 512);

uv_region = hsv_crop(img);

% save for python stuff with OpenCV and SAM
if isfloat(uv_region)
    uv_region_uint8 = im2uint8(uv_region);
else
    uv_region_uint8 = uv_region;
end

imwrite(uv_region_uint8, 'uv_region.jpg', 'jpg', 'Quality', 95);