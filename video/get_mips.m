function get_mips(rawfiles, stride, start, stop, type)
% GET_MIPS Create and save intensity projections/time lapse images for RAW files
%
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb)
%  
% This function computes and saves a Maximum or Minimum Intensity 
% Projection image for any RAW file matching "rawfiles".
%  
%  [im] = get_mips(rawfiles, stride, start, stop, type);
%   
%  where "rawfiles" is the name of the rawfile (wildcards accepted) 
%        "stride" is the number of frames to jump between "start" and "stop"
%        "start" is the frame number where the mip should start computing
%        "stop" is the frame number where the mip should stop computing
%

if nargin < 5 | isempty(type);      type = 'min';        end;
if nargin < 4 | isempty(stop);      stop = [];           end;
if nargin < 3 | isempty(start);     start = 1;           end;
if nargin < 2 | isempty(stride);    stride = 8;          end;
if nargin < 1 | isempty(rawfiles);  rawfiles = '*.raw';  end;

if ~strcmp(type, 'min') && ~strcmp(type, 'max') && ~strcmp(type, 'mean')
    warning('MIP type unknown, defaulting to minimum.');
    type = 'min';
end

rawfiles = dir(rawfiles);

for k = 1 : length(rawfiles)
    imMIP = mip(rawfiles(k).name, start, stop, stride, type);
    
    new_filename = [rawfiles(k).name(1:end-3) 'MIP.bmp'];
    
    imwrite(imMIP, colormap(gray(256)), new_filename, 'BMP');    
end

