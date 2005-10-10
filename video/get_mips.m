function get_mips(rawfiles)
% 3DFM function  
% Image Analysis 
% last modified 01/26/05
%  
% This function computes and saves a Maximum or Minimum Intensity 
% Projection image for any RAW file matching <rawfiles>.
%  
%  [im] = get_mips(rawfiles);  
%   
%  where "rawfiles" is the name of the rawfile (wildcards accepted) 
%  
%  Notes:  
%   
%  01/26/05 - created; jcribb.
%   
%  

rawfiles = dir(rawfiles);

for k = 1 : length(rawfiles)
    imMIP = mip(rawfiles(k).name, 1, [], 8, 'min');
    
    new_filename = [rawfiles(k).name(1:end-3) 'MIP.bmp'];
    
    imwrite(imMIP, gray, new_filename, 'BMP');    
end
