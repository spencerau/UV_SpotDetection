
function filtered_img = woodgrain_filter(img)
    bw = img;

    minLen = 10;
    % for each orientation of wood grain or true line:
    angs = [-15, -30, 15, 30, 120];  
    for theta = angs
        se = strel('line', minLen, theta);
        bw = imopen(bw, se);
    end
    
    filtered_img = bw;

end

