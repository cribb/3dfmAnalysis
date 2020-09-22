function out_im = VST_blur_and_center_surround(im, blur_lost_and_found, center_surround, scaleopt)
% VST_BLUR_AND_CENTER_SURROUND generates the same blurred image as CISMM's Video Spot Tracker
%
% 3DFMAnalysis function
% tracking
%
% [out_im] = VST_blur_and_center_surround(im, blur_lost_and_found, center_surround, scaleopt)
%
% where "im" is the inputted image (uint8 works, not sure about uint16, etc.)
%       "blur_lost_and_found" is blur factor used by Video Spot Tracker (VST),
%            these values can be found in VST config files
%       "center_surround" is another blurring factor, also found in VST
%            config files
%       "scaleopt" -- set this to 'scale' to set the output such that the 
%            maximum pixel value is scaled to 255 and the min set to 0.
%

% Create the gaussian filter with hsize = [5 5] and sigma = blur_lost_and_found
myblur = fspecial('gaussian', [4 4], blur_lost_and_found);

% now do the same for the larger center-surround version
mycs = fspecial('gaussian', [4 4], blur_lost_and_found + center_surround);

%# Filter it
filtblur = imfilter(im, myblur, 'same');
filtcs   = imfilter(im, mycs, 'same');


% If matlab version is 2015 or better, then the following code is more
% efficient
%     filtblur = imgaussfilt(im, blur_lost_and_found);
% 
%     filtcs = imgaussfilt(im, blur_lost_and_found+center_surround);
% 
%     im = filtblur - filtcs + 0.5;

im = filtblur - filtcs + 0.5;

if strcmp(scaleopt, 'scale')
    im = double(im);
    im = im - min(im(:));
    im = im / max(im(:));
end

out_im = im;

return;