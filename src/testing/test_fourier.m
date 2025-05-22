% testing only
clc
clear

img = imread('Final Project/assets/uv_1.jpg');

img = custom_resize(img, 512);

uv_region = hsv_crop(img);

fourier_mask = FourierMask(uv_region);

spot_mask = woodgrain_filter(fourier_mask);

lineMask = line_mask(fourier_mask);

figure
subplot(2,2,1); imshow(uv_region); title("Cropped UV Image");
subplot(2,2,2); imshow(fourier_mask); title("Fourier Mask");
subplot(2,2,3); imshow(spot_mask); title('Filter out Wood Grains');
subplot(2,2,4); imshow(lineMask); title("Using HSV Line Mask");

