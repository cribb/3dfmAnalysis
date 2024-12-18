function [meanSNR, stdSNR, DataOut] = snr_batch_calc(filepath, filemask, circle_radius, sensitivity, overfill)
% SNR_BEADIMAGE calculates signal-to-noise ratio for a microscopy image 
%
% The function snr_beadimage finds circular objects and segments them out
% in an attempt to calculate signal-to-noise (SNR). The maximum pixel
% intensity of each circular object is used as signal. The average value
% of the remaining pixels serves as the background measurement, while its
% standard deviation estimates the noise.
% 
% [snrmean, snrstd, T] = snr_beadimage(image, circle_radius, sensitivity, overfill, report)
% 
% Output parameters:
%   snrmean  mean SNR computed from each circular (signal) object
%   snrstd   standard deviation for signal distribution
%   T        output data table for individual objects.
%
% Input parameters:
%   filepath        path to files in filemas. Use '.'  for current directory
%   filemask        string that defines the file search mask. Ex.: '*.tif'
%   circle_radius   estimated average pixel radius for objects of interest
%   sensitivity     "dial" for optimizing object detection, usually between
%                   0.8 - 0.97. More than 0.97 risks false positive signals
%   overfill        size "factor" for object segmentation. A value of 1
%                   means the object mask will be the same as measured by
%                   the object finding algorithm, where a value of 2 would
%                   double the effective radii of objects in the image
%

cd(filepath);

if nargin < 1 || isempty(filepath)
    error('File path needed.');
end

if nargin < 2 || isempty(filemask)
    error('File mask needed. A specific filename is also fine.');
end

if nargin < 3 || isempty(circle_radius)
    error('Expected bead radius in pixels required.');
end

if nargin < 4 || isempty(sensitivity)
    sensitivity = 0.95;
end

if nargin < 5 || isemtpy(overfill)
    overfill = 5;
end

filelist = dir(filemask);

if isempty(filelist)
    error('No files found. Wrong file name/mask?');
end

N = numel(filelist);

meanSNR = NaN(N,1);
stdSNR = NaN(N,1);
DataOut = cell(N,1);
for fid = 1:N
    filename = filelist(fid).name;

    im = imread(filename);

    [meanSNR(fid), stdSNR(fid), DataOut{fid}] = snr_beadimage(im, circle_radius, sensitivity, overfill, 'n');
end

