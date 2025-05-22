% testing only
clc
clear

img = imread('Final Project/assets/uv_4.jpg');

img = custom_resize(img, 512);

uv_region = hsv_crop(img);

exg_mask = ExcessGreenMask(uv_region);

figure
subplot(1,2,1); imshow(uv_region); title("Cropped UV Image");
subplot(1,2,2); imshow(exg_mask); title("Excess Green Mask (RGB)");

