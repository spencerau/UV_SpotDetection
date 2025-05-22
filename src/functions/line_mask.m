
function lineMask = line_mask(bw)

  skeleton = bwmorph(bw, 'skel', Inf);
  [L, n] = bwlabel(skeleton);

  stats = regionprops(L, 'PixelIdxList','Eccentricity');
  lineMask = false(size(bw));

  min_len = 170;
  % only lines
  ecc_thresh = 0.99; 

  for k = 1:n
    pixList = stats(k).PixelIdxList;
    if numel(pixList) >= min_len && stats(k).Eccentricity >= ecc_thresh
      lineMask(pixList) = true;
    end
  end

  % fatten lines a little
  lineMask = imdilate(lineMask, strel('disk',1));
end