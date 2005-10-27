function get_mips(rawfiles, stride)
% 3DFM function  
% Image Analysis 
% last modified 01/26/05
%  
% This function computes and saves a Maximum or Minimum Intensity 
% Projection image for any RAW file matching "rawfiles".
%  
%  [im] = get_mips(rawfiles, stride);  
%   
%  where "rawfiles" is the name of the rawfile (wildcards accepted) 
%        "stride" is the number of frames to jump between "start" and "stop"
%   
%  01/26/05 - created; jcribb.
%   
%  

if nargin < 2 | isempty(stride);
    stride = 8;
end

if nargin < 1 | isempty(rawfiles);
    rawfiles = '*.raw';
end

rawfiles = dir(rawfiles);

for k = 1 : length(rawfiles)
    imMIP = mip(rawfiles(k).name, 1, [], stride, 'min');
    
    new_filename = [rawfiles(k).name(1:end-3) 'MIP.bmp'];
    
    imwrite(imMIP, colormap(gray(256)), new_filename, 'BMP');    
end
