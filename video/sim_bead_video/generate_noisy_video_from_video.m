function [] = generate_noisy_video_from_video( first_frame_name, n_of_frames, saved_frame_dir)
%
% this function does the following:
% for the given first frame name, and number of frames, it reads the
% frame name and add noise and save the new frame into the given dir.

% assume the frame file name format is xxx%04d.png

% noise consists of:
%                   Gaussian noise with mean 0 and std dev xxx 
%                   Posssion noise with lambda xxx 



%
%J = imnoise(I,'gaussian',m,v) adds Gaussian white noise of mean m and
%   variance v to the image I. The default is zero mean noise with 0.01 variance.

%J = imnoise(I,'poisson') generates Poisson noise from the data instead
%   of adding artificial noise to the data. If I is double precision, 
%   then input pixel values are interpreted as means of Poisson distributions
%   scaled up by 1e12. For example, if an input pixel has the value 5.5e-12, 
%   then the corresponding output pixel will be generated from a Poisson distribution
%   with mean of 5.5 and then scaled back down by 1e12. If I is single precision, the 
%   scale factor used is 1e6. If I is uint8 or uint16, then input pixel values are used 
%   directly without scaling. For example, if a pixel in a uint8 input has the value 10, 
%    then the corresponding output pixel will be generated from a Poisson distribution with mean 10.

%

frame_header = first_frame_name(1:size(first_frame_name,2)-8);
for i = 1:n_of_frames
    
    frame_name = strcat(frame_header, sprintf('%04d',i), '.png');
    curr_img = imread(frame_name);
    
    % add noise
    noiseG = imnoise(curr_img,'gaussian');
    noiseP = imnoise(curr_img,'poisson');
    
    pureP = int16(noiseP) - int16(curr_img);
    
    noiseGP = uint8(int16(noiseG) + int16(pureP));
    
    imwrite(noiseGP,strcat(saved_frame_dir,'/nframe',sprintf('%04d',i),'.png'));
end
end
