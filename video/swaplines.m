function imnew = swaplines(im)
% SWAPLINES Recovers scrambled lines incorrectly scanned by Pulnix for an image.
%
% 
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb) 
% 

 oddlines = [1:2:size(im,1)]';
 evenlines = [2:2:size(im,1)]';
 
 imODD = im(oddlines, :);
 imEVEN = im(evenlines, :);
 
 imnew = zeros(size(im));
 
 imnew(oddlines,:) = imEVEN;
 imnew(evenlines,:) = imODD;
 