clear
clc
close all


addpath(genpath(fullfile(pwd, 'src/functions')));

img = imread('assets/uv_1.jpg');
%img = imread('assets/uv_bedroom_2.jpg');

function [] = detect_uv_spot(img, is_wood)

    img = custom_resize(img, 512);
    
    uv_region = hsv_crop(img);
    
    exg_mask = ExcessGreenMask(uv_region, 98);
    
    if ~is_wood
        % in the bedroom carpet only using RGB ExG is sufficient
        figure
        subplot(1,3,1); imshow(img); title('Original Image');
        subplot(1,3,2); imshow(uv_region); title('HSV-Based Crop');
        subplot(1,3,3); imshow(exg_mask); title('Excess Green Mask');
    
    elseif is_wood
            
        grayscale = rgb2gray(uv_region);
        
        threshold = uv_threshold(grayscale);
        
        spot_mask = woodgrain_filter(threshold);
        
        lineMask = line_mask(threshold);

        fourier_mask = FourierMask(uv_region);
        
        combinedMask = spot_mask | lineMask | exg_mask | fourier_mask;
        
        figure
    
        subplot(3,3,1); imshow(img); title('Original Image');
        subplot(3,3,2); imshow(uv_region); title('HSV-Based Crop');
        subplot(3,3,3); imshow(threshold); title('Detected Fluorescent Spots');
        subplot(3,3,4); imshow(exg_mask); title('Excess Green Mask (RGB Space)');
        subplot(3,3,5); imshow(spot_mask); title('Filter out Wood Grains');
        subplot(3,3,6); imshow(lineMask); title("Using HSV Line Mask");
        subplot(3,3,7); imshow(fourier_mask); title("Fourier Mask");
        subplot(3,3,8); imshow(uv_region); title("Comparison Image");
        subplot(3,3,9); imshow(combinedMask); title("Combined Masks");
        
    end
end

detect_uv_spot(img, true);

