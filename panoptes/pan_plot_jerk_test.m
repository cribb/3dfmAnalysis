function dataout = pan_plot_jerk_test(filepath, mytitle)

cd(filepath);
filelist = dir('jerk*.csv');

for k = 1 : length(filelist)
    
    fname = filelist(k).name;
    
    A = importdata(fname, ',', 1);
    
    sidx = regexp(fname, '[0-9]');

    channel_name{k} = fname(sidx);
    channel(k) = str2num(fname(sidx));
    
    elapsed_time(:,k) = A.data(:,1);
    image_error(:,k) = A.data(:,2);
    
end

[~,sortorder] = sort(channel);

elapsed_time = elapsed_time(:, sortorder);
image_error = image_error(:, sortorder);

channel_name = channel_name(sortorder);

figure; 
plot(elapsed_time, image_error, '.-');
xlabel('elapsed time [s]');
ylabel('image error');
legend(channel_name);
title(mytitle);
pretty_plot;

dataout.channel_name = channel_name;
dataout.elapsed_time = elapsed_time;
dataout.image_error = image_error;

return;
