
function [ExG_Mask] = ExcessGreenMask(rgb_img)

    I = im2double(rgb_img);
    R = I(:,:,1);                  
    G = I(:,:,2);
    B = I(:,:,3);
    maskCircle = any(I>0,3);
    
    % 1) compute Excess‑Green index
    ExG = 2*G - R - B;  

    mn = min(ExG(:));  
    mx = max(ExG(:));  
    fprintf("ExG goes from %.2f to %.2f\n", mn, mx);

    % normalized equalition for Excess Green
    ExGn = (ExG - mn)/(mx - mn);

    thresh = prctile(ExGn(maskCircle), 98.5);
    % 
    % adapt_thresh = adaptthresh(ExGn, 0.6, ...
    %     'NeighborhoodSize',[41 41], ...
    %     'Statistic', 'mean', ...
    %     'ForegroundPolarity', 'bright');

    %m = imbinarize(ExGn, adapt_thresh) & maskCircle;

    m= ExGn > thresh & maskCircle;

    m = m & maskCircle;
    se = strel('disk',6);
    m = imclose(m,se);
    m = imfill(m,'holes');

    % keep all connected blobs ≥40 pixels
    m = bwareafilt(m, [40 Inf]);

    ExG_Mask = m;
    
end

