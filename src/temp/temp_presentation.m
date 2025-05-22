clear
clc

img = imread('Final Project/assets/uv_1.jpg');

img = custom_resize(img, 512);

uv_region = hsv_crop(img);

grayscale = rgb2gray(uv_region);

threshold = uv_threshold(grayscale);

spot_mask = woodgrain_filter(threshold);

lineMask = line_mask(threshold);

combinedMask = spot_mask | lineMask;

figure
imshow(combinedMask);