function v = balance_pulnix_gains(im)
% BALANCE_PULNIX_GAINS Equilibrates interlaced gains for images from Pulnix Camera
%
% 3DFM function 
% Image Analysis 
% last modified 2008.11.14 (jac)
%  
% This function attempts to equilibrate the gains between the 
% two channels of the Pulnix PTM-6710 camera.  These channels are
% interlaced, and sometimes a 'banded' appearance occurs when 
% looking at a Pulnix image with contrast enhancement.  The average 
% pixel value is computed each for the even and odd lines of the 
% image, and added to the set of lines with the lower value.  The
% entire image is then renormalized such that the maximum value
% in the matrix is 1.
%  
%  [v] = function_name(im);  
%   
%  where "im" is a matrix representing a Pulnix image.
%   


% im = imadjust(im, stretchlim(im), [0 1]); % contrast enhance first.
im = double(im(:,:,1));

[rows cols] = size(im);

oddlines = [1:2:rows]';
evenlines = [2:2:rows]';

avg_odd_value = mean(mean(im(oddlines,:)));
avg_even_value= mean(mean(im(evenlines,:)));

if avg_odd_value < avg_even_value   
    gain = avg_even_value / avg_odd_value;    
    im(oddlines,:) = gain * im(oddlines,:);
else
    gain = avg_odd_value / avg_even_value;    
    im(evenlines,:) = gain * im(evenlines,:);
end

v = im;


