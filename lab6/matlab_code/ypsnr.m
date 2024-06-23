function P = ypsnr(im1,im2)
% Compute the PSNR between luminance images

error = double(im1)-double(im2);
P = 10*log10(255*255/mean(error(:).^2));
