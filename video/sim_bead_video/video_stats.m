function [stats_table,num_pix] = video_stats(files)
% must be in the directory of the video you want to analyze 
% files is what all the filenames have in common, must be a string

list = dir([files '*']);
firstframe = imread(list(1).name);
max_I = max(max(firstframe));
%logentry(['Maximum intensity of first frame is ' num2str(max_I) '.']);

num_frames = length(list);

switch max_I
    case 255;
        logentry('Frames are 8-bit images.');
    case 4095;
        logentry('Frames are 12-bit images.');
    case 65535
        logentry('Frames are 16-bit images.');
    otherwise 
        logentry('No photobleaching occurs');
        num_pix = [];
        return;
end

stats = zeros(num_frames,6);
num_pix = zeros(1,length(list));

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
    
    bleached = (frame == max_I);
    count = sum(sum(bleached));
    num_pix(i) = count;
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