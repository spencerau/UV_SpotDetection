
function [uv_region] = hsv_crop(img)
    % convert to HSV so we can pull hue, saturation, brightness
    hsv_img = rgb2hsv(img);
    hue = hsv_img(:,:,1);
    sat = hsv_img(:,:,2);
    bright = hsv_img(:,:,3);

    brightMin = mean(bright(bright>0)) + 0.10;

    % hue of 0.6 - 0.75 is roughly where purple/blue is for UV light
    uv_mask = (hue > 0.55) & (hue < 0.8) & (sat >= 0.2) & (bright >= brightMin);

    % grab largest blob
    uv_mask = bwareafilt(uv_mask, 1);

    % use regionprops for blobs/circles
    stats = regionprops(uv_mask, 'Centroid', 'EquivDiameter', 'BoundingBox');

    if isempty(stats)
        uv_region = [];
        return;
    end

    % create circular mask
    center = stats.Centroid;
    radius = stats.EquivDiameter / 2 + 25; % 25 pixel offset
    [X, Y] = meshgrid(1:size(img,2), 1:size(img,1));
    circle_mask = ((X - center(1)).^2 + (Y - center(2)).^2) <= radius^2;

    masked_img = img;
    for c = 1:3
        channel = masked_img(:,:,c);
        channel(~circle_mask) = 0;
        masked_img(:,:,c) = channel;
    end

    % apply circular mask to bounding box for "circular" output
    bbox = stats.BoundingBox;
    x = max(round(bbox(1)), 1);
    y = max(round(bbox(2)), 1);
    w = round(bbox(3));
    h = round(bbox(4));
    uv_region = masked_img(y:y+h-1, x:x+w-1, :);
end
    