function outs = video_stats(files, outstyle, report)
% must be in the directory of the video you want to analyze 
% files is what all the filenames of the frames have in common, must be a string
if nargin < 3 || isempty(report)
    report = 'no';
end

if nargin < 2 || isempty(outstyle)
    outstyle = 'dataset';
end

list = dir(files);
firstframe = imread(list(1).name);

bits = class(firstframe);
num_frames = length(list);


if isa(firstframe, 'uint8');
    maximum_I = 255;
    logentry('8-bit images.');
elseif isa(firstframe, 'uint12')
    maximum_I = 4095;
    logentry('12-bit images.');
elseif isa(firstframe, 'uint16')
    maximum_I = 65535;
    logentry('16-bit images.');
else
    error('unknown file type');
end


stats = zeros(num_frames,7);

for i = 1:num_frames
    frame = imread(list(i).name);
    
    stats(i,1) = mean(frame(:));
    stats(i,2) = median(frame(:));
    stats(i,3) = mode(frame(:));
    stats(i,4) = std(double(frame(:)));
    stats(i,5) = max(frame(:));
    stats(i,6) = min(frame(:));
    stats(i,7) = sum(sum(frame == maximum_I));

end

stats_table = mat2dataset(stats);
stats_table.Properties.VarNames = {'Mean' 'Median' 'Mode' 'Standard_Deviation' 'Maximum' 'Minimum' 'Bleach_Count'};
stats_struct = dataset2struct(stats_table, 'AsScalar', true);

[~, currentfolder, ~] = fileparts(pwd);

if strcmp(report, 'y')
    figure;
    plot(stats);
    title(['Stats for ' currentfolder], 'Interpreter', 'none');
    xlim([0 num_frames]);
    xlabel('Frame Number');
    legend('Mean','Median','Mode','Standard Deviation','Maximum','Minimum');
    grid on;
end

if sum(stats_table.Bleach_Count) == 0
    logentry('No photobleaching occurs.');
end

logentry('Finished analysis.')

if strcmp(outstyle, 'struct')
    outs = stats_struct;
else
    outs = stats_table;
end

end