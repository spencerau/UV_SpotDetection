
function [threshold_img] = uv_threshold(img)

    grayscale = img;
    % ignore pure black from circular mask
    valid_mask = grayscale > 10;
    grayscale(~valid_mask) = 0;

    % remove noise
    denoise = medfilt2(grayscale, [5 5]);
    
    % use adaptive histogram equalization to enhance contrast
    enhanced = adapthisteq(denoise, 'ClipLimit', 0.01);
  
    T = adaptthresh(enhanced, ...
                    0.45, ...    % need to tweak this sensitivity value?                   
                    'ForegroundPolarity','bright', ...
                    'NeighborhoodSize',[25 25], ...
                    'Statistic','median');
    bw = imbinarize(enhanced,T);

    % morphological closing = dilation followed by erosion
    bw = imclose(bw, strel('disk', 2));
    % remove small blobs (noise or premium cat litter)
    threshold_img = bwareafilt(bw, [30 Inf]);
    % fill in black holes within white fluorescent blobs
    threshold_img = imfill(threshold_img,'holes');
  
end

