function mask = fluorescence_mask(rgb_img)
    hsv    = rgb2hsv(rgb_img);
    hue    = hsv(:,:,1);
    sat    = hsv(:,:,2);
    bright = hsv(:,:,3);

    % compute brightness cutoff (top 10% of nonzero pixels)
    %Vthr = prctile(bright(bright>0),90);
    % Vthr = prctile(bright(bright>0),80);
    Vthr = graythresh(bright(bright>0));  % returns a [0–1] threshold via Otsu

    % bring hue back in to isolate only the fluorescence colour
    hueMin = 0.55;  hueMax = 0.80;
    satMin = 0.30;

    mask = (hue>=hueMin & hue<=hueMax) ...
         & (sat>=satMin) ...
         & (bright>Vthr);

    mask = bwareaopen(mask, 50);                   % drop tiny specks
    mask = imopen(mask, strel('disk',2));          % smooth
    mask = imfill(mask,'holes');
    mask = imclose(mask, strel('disk',3));         % polish edges
end