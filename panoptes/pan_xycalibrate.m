function outs = pan_xycalibrate(filelist, linenumber, um_per_division)
% PAN_XYCALIBRATE  Computes XY calibration for a set of graticule images
%
% Panoptes function
%
% This function
% 
% outs = xycalibrate(filenames, linenumber, um_per_division)
%
% where 'outs' is a matrix containing the calibration data
%       'filenames' is a list of files (wildcards accepted, e.g. '*.png')
%       'linenumber' refers to the pixel line to use for the computation
%       'um_per_division' is the microns per division found on the graticule
%

% default values
if nargin < 1 || isempty(filelist)
    filenames = dir('*.png');
end

if nargin < 2 || isempty(linenumber)
    linenumber = 200;
end

if nargin < 3 || isempty(um_per_division)
    um_per_division = 10;
end

for k = 1:length(filenames)
    myfile = filenames(k).name;
    MCUnum_idx = regexp(myfile, '[0-9]');
    MCUnum(k,1) = str2num(myfile(MCUnum_idx));
    im = imread(myfile);
    im = im(:,:,1);
    im_line = im(linenumber,:);
    pixel = [1:length(im_line)];
    
    di = CreateGaussScaleSpace(double(im_line(:)),1,12);
    [pks,locs]=findpeaks(di);

    % stats
    pixel_distance_between_peaks = diff(locs);
    um_distance_between_peaks = um_per_division ./ pixel_distance_between_peaks;

    pd_mean(k,1) = mean(pixel_distance_between_peaks);
    pd_std(k,1)  = std(pixel_distance_between_peaks);
    pd_ste(k,1)  = std(pixel_distance_between_peaks) ./ sqrt(length(pixel_distance_between_peaks)-1);

    um_mean(k,1) = mean(um_distance_between_peaks);
    um_std(k,1)  = std(um_distance_between_peaks);
    um_ste(k,1)  = std(um_distance_between_peaks) ./ sqrt(length(um_distance_between_peaks)-1);

%         % plots
%         h = figure; 
%         subplot(1,2,1);
%         plot(pixel,di,pixel(locs),pks, 'r.');
%         xlabel('x pixel location');
%         ylabel('smoothed 1st derivative of luminance');
% 
%         subplot(1,2,2);
%         plot(pixel_distance_between_peaks);
%         ylabel('pixel distances between divisions');


    % text output
    % fprintf('Distances between markers (pixels): %s \n', num2str(pixel_distance_between_peaks(:)'));
    % fprintf('Mean distance (pixels): %5.2f \n', pd_mean);
    % fprintf('Std dev (pixels): %5.4f \n', pd_std);
    % fprintf('Std err (pixels): %5.4f \n\n', pd_ste);
    % 
    % fprintf('\nThis corresponds to a XY length calibration of: \n');
    % fprintf('Mean distance (pixels): %5.4f [um/px] \n', um_mean);
    % fprintf('Std dev (pixels): %5.4f [um/px]\n', um_std);
    % fprintf('Std err (pixels): %5.4f [um/px]\n\n', um_ste);
end

% outfiles = 
outs = sortrows([MCUnum, pd_mean, pd_std, pd_ste, um_mean, um_std, um_ste],1);