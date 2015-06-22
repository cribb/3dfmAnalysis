function [] = generate_noise_tif(filename_format, in_struct, mean, stdev)
%Gen
%
%Inputs
%   -filename_format is the common part of the file names of your group of
%   images (ie. frame_0000, frame_0001, frame_0002, etc. would have
%   filename_format of 'frame_')
%       *filenames must have format of 'filename_format' followed by a four
%       digit number
%   -num_frames is the number of frames in the video
%   -variance is the variance of the gaussian noise that you are simulating

numframes = in_struct.frame_rate*in_struct.duration;

stdev = stdev/255;

for n = 1:numframes
    orig_frame_name = [filename_format sprintf('%04d',(n-1)) '.tif'];
    orig_frame = imread(orig_frame_name);
    
    imsize = size(orig_frame);
    
    noise = uint8(mean + stdev .* randn(imsize(1),imsize(2)));
    
    new_frame = orig_frame + noise;
    
    imwrite(new_frame,orig_frame_name);
    
end
end