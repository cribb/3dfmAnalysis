function [stats_table,num_pix] = video_stats(files)
% must be in the directory of the video you want to analyze 
% files is what all the filenames of the frames have in common, must be a string

list = dir([files '*']);
firstframe = imread(list(1).name);

bits = bitdepth(list(1).name);
num_frames = length(list);


if bits == 8
    maximum_I = 255;
    logentry('8-bit images.');
elseif bits == 12
    maximum_I = 4095;
    logentry('12-bit images.');
elseif bits == 16
    maximum_I = 65535;
    logentry('16-bit images.');
end


stats = zeros(num_frames,6);
num_pix = zeros(1,num_frames);

for i = 1:num_frames
    frame = imread(list(i).name);
    
    mean_I = mean(frame(:));
    stats(i,1) = mean_I;
    
    median_I = median(frame(:));
    stats(i,2) = median_I;
    
    mode_I = mode(frame(:));
    stats(i,3) = mode_I;
    
    stdev_I = std(double(frame(:)));
    stats(i,4) = stdev_I;
    
    max_I_frame = max(frame(:));
    stats(i,5) = max_I_frame;
    
    min_I = min(frame(:));
    stats(i,6) = min_I;
    
    bleached = (frame == maximum_I);
    count = sum(sum(bleached));
    num_pix(i) = count;
end

if count == 0
    logentry('No photobleaching occurs.');
end

stats_table = mat2dataset(stats);
stats_table.Properties.VarNames = {'Mean' 'Median' 'Mode' 'Standard_Deviation' 'Maximum' 'Minimum'};

folder = pwd;
[path, currentfolder, ~] = fileparts(folder);

figure;
plot(stats);
title(['Stats for ' currentfolder]);
xlim([0 num_frames]);
xlabel('Frame Number');
legend('Mean','Median','Mode','Standard Deviation','Maximum','Minimum');

figure;
plot(num_pix);
title(['Overexposed pixels in ' currentfolder]);
xlabel('Frame Number');
ylabel('Number of Overexposed Pixels');
axis([0 num_frames 0 (max(num_pix)+10)]);

logentry('Finished analysis.')

end