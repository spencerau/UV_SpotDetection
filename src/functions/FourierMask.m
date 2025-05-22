function [bw] = FourierMask(img)

    maskCircle = any(img>0, 3);
    cropGray = double(rgb2gray(img));
    cropGray(maskCircle==0) = 0;

    % 2d Fourier 
    F = fftshift(fft2(double(cropGray)));
    mag = log(1 + abs(F));  
    %imshow(mag,[]);  % visualize frequency spectrum

    % radial band pass mask
    [M,N] = size(cropGray);
    [U,V] = meshgrid( (-N/2:N/2-1)/(N) , (-M/2:M/2-1)/(M) );
    R  = sqrt(U.^2 + V.^2);

    bw_frac = 0.5;  
    D = 40;
    f_low  = 1/D * (1 - bw_frac);
    f_high = 1/D * (1 + bw_frac);

    maskF = (R >= f_low) & (R <= f_high);

    % apply filter and invert
    Ffilt = F .* maskF;
    resp = real(ifft2(ifftshift(Ffilt)));
    
    %imagesc(resp);
    resp = mat2gray(resp);
    % need to apply a strict filter to get rid of wood patterns
    bw = resp > 0.7;

    bw = bw & maskCircle;
    % zero out 200 pix border around to avoid circle
    bw(1:200, :) = false;
    bw(end-200+1:end, :) = false;
    bw(:, 1:200) = false;
    bw(:, end-200+1:end) = false;

    %imagesc(bw);

end

