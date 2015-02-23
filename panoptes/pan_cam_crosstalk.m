function outs = pan_cam_crosstalk(filepath, numframes)
% PAN_CAM_CROSSTALK analyzes the output of a Panoptes run that only contains blank videos.
%
% Panoptes function 
% 
% This function is used as a diagnostic for the cameras in the Panoptes
% system.  
% of data into a 'plate-shaped' matrix that will correspond with the
% multiwell plate geometry used the Panoptes high-throughput system.
% 
% outs = pan_cam_crosstalk(filepath, numframes) 
%
% where "outs" is a structure that contains the results for each channel as follows
%               .stats is a structure containing statistical information
%                      per frame (row) for all channels (columns)
%               .mean_col is a 2D matrix containing all of the mean_columns
%                         computed for that channel
%               .mean_row is a 2D matrix containing all of the mean_rows
%                         computed for that channel
%       "filepath" is a file path that contains a complete set of collected
%                  Panoptes data.
%       "numframes" is the number of consecutive frames to analyze for a
%                   given video
%

if nargin < 2 || isempty(numframes)
    numframes = 200;
end

% test dataset
% filepath = 'D:\jcribb\2013_10_24__empty_frame';

systemid = 'panoptes';
platetype = '96well';

cd(filepath);

filelist = dir('*video*');
filelist = filelist([filelist.isdir]);

% load run metadata
metadata = pan_load_metadata(filepath, systemid, platetype);

frame_rate = metadata.instr.fps_fluo;
% frame_rate = 38.16;

% for all the videos in a particular run
for k = 1:length(filelist)
% for k = 1:1    
    myfile = filelist(k).name;

    % go into the video subfolder
    cd(myfile);
    
    [well(1,:) pass(1,:)] = pan_wellpass(myfile);
    channel(1,k) = pan_get_channel_id(well);

    
    imglist = dir('frame*.pgm');
    imglist = imglist(1:numframes);    
    imgClip = 100;
    
    framelist = 1:length(imglist);
    
    time = (framelist-1) * 1/frame_rate;

    fprintf('Working on: %s,  ', filelist(k).name);

    % start the reported position of the code (this code takes a long time to run)
    fprintf('Frame: 0 ');
    
    % for each of the frames in a given video
    for frameIDX = 1:length(imglist)

        % Print every 100th index just to give a good idea where the code is.
        if ~mod(frameIDX,100)
            fprintf(' %i ', frameIDX);
        end

        % pull in the image & cast to double
        im = imread(imglist(frameIDX).name);              
        im = double(im);
        
        npx_horz = size(im,2);
        npx_vert = size(im,1);

        % Video statistics for the entire frame on a per frame basis
        a_pixel_location = floor(size(im)/2);
        a_pixel_through_time(frameIDX,k) = im(a_pixel_location(:,1),a_pixel_location(:,2));
        mean_lum(frameIDX,k) = mean(im(:));  %#ok<*AGROW,*NASGU>
        median_lum(frameIDX,k) = median(im(:));
        stdev_lum(frameIDX,k) = std(im(:));
        min_lum(frameIDX,k) = min(im(:));
        max_lum(frameIDX,k) = max(im(:));
        mode_lum(frameIDX,k) = mode(im(:));
        
        % Computing the mean row and mean column of each frame and adding
        mean_rows(frameIDX,:,k) = mean(im,1); % average row for each frame [1:frameIDX, 1:npx_vert]
        mean_columns(:,frameIDX,k) = mean(im, 2);
                
    end
    
    % wrap up our frame count line for the next run through the for loop
    fprintf('\n');

    % return to the root data directory
    cd('..');
    
% % Plots all of the pertinent information for each channel separately
%     h = figure; 
%     set(h, 'Name', ['Channel ' num2str(channel(k))]);
%     set(h, 'Units', 'normalized');
%     set(h, 'Position', [0.2 0.1 0.4 0.8]);
%     subplot(3,2,1);
%     plot(time, [min_lum, mean_lum, max_lum]);
%     xlabel('time [s]');
%     ylabel('px lum');
%     legend('min', 'mean', 'max');
% 
%     subplot(3,2,3);
%     imagesc(time(1:imgClip), 1:npx_vert, mean_column(:,1:imgClip)); 
%     colormap(hot);
%     xlabel('time [s]');
%     ylabel('avg(col) over time');
%     colorbar;
% 
%     subplot(3,2,4);
%     imagesc(1:npx_horz, time(1:imgClip), mean_row(1:imgClip,:)); 
%     colormap(hot);
%     xlabel('avg(row) over time');
%     ylabel('time [s]');
%     colorbar;
% 
%     subplot(3,2,5);
%     plot(time, avg_pixel_through_time);
%     xlabel('time [s]');
%     ylabel('px luminance');
%     
%     % Plot single-sided amplitude spectrum.
%     subplot(3,2,6);
%     plot(f, magY(:,k));
% %     title('Single-Sided Amplitude Spectrum of y(t)')
%     xlabel('Frequency (Hz)')
%     ylabel('|Y(f)|');
%     title(['Channel ' num2str(channel(k))]);  
%     
end

% pull out temporal data from mean columns
avg_col_pixel_location = 250;
avg_pixel_through_time = squeeze(mean_columns(avg_col_pixel_location,:,:));
offset = mean(avg_pixel_through_time,1);
avg_pixel_through_time = avg_pixel_through_time - repmat(offset, numframes,1);

% freq analysis
Fs = frame_rate;
T = 1/Fs;
y = avg_pixel_through_time;
L = length(y);
t = (0:L-1)*T;

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
magY = 2*abs(Y(1:NFFT/2+1,:));
    
% sort everything according to the correct channel order
[sorted_channelid, channel_order] = sort(channel);
magY = magY(:, channel_order);
mean_columns = mean_columns(:,:,channel_order);
mean_rows = mean_rows(:,:,channel_order);

mean_lum = mean_lum(:,channel_order);
median_lum = median_lum(:,channel_order);
mode_lum = mode_lum(:,channel_order);
stdev_lum = stdev_lum(:,channel_order);
min_lum = min_lum(:,channel_order);
max_lum = max_lum(:,channel_order);    
        
% set up outputs 
outs.framestats.channel = transpose(sorted_channelid(:));
outs.framestats.framenumber(:,1) = 1:numframes;
outs.framestats.mean = mean_lum;
outs.framestats.stdev = stdev_lum;
outs.framestats.median = median_lum;
outs.framestats.mode = mode_lum;
outs.framestats.min = min_lum;
outs.framestats.max = max_lum;
outs.mean_columns = mean_columns;
outs.mean_rows = mean_rows;
outs.avg_col_pixel_over_time = avg_pixel_through_time;
outs.avg_col_pixel_location = avg_col_pixel_location;
outs.a_pixel_over_time = a_pixel_through_time;
outs.a_pixel_location = a_pixel_location;
outs.time = t;
outs.channelFFT = magY;


% % NOW TO DEAL WITH PLOTTING

% set up global axes across all channel data    
colCLim = [0 max(mean_columns(:))];
rowCLim = [0 max(mean_rows(:))];


    FRAMEfig = figure;
    set(FRAMEfig, 'Name', 'Frame stats over time');
    set(FRAMEfig, 'Units', 'Normalized');
    set(FRAMEfig, 'Position', [0.1 0.1 0.8 0.6]);
    yaxis_limits = [min(min_lum(:))-0.1 max(max_lum(:))+2];
    for k = 1:length(sorted_channelid)
        figure(FRAMEfig);
        subplot(2,6,k);
        hold on;
            plot(t, min_lum(:,k), 'r');
            plot(t, mean_lum(:,k), 'k');
            plot(t, median_lum(:,k), 'b');
            plot(t, mode_lum(:,k), 'g');
            plot(t, max_lum(:,k), 'r');
        hold off;
        set(gca, 'YLim', yaxis_limits);
        title(['Channel ' num2str(sorted_channelid(k))]);
        xlabel('time [s]');
        ylabel('Pixel Value');
        if k==6
            legend('min', 'mean', 'median', 'mode', 'max', 'Location', 'EastOutside');
        end
    end
    
    STATSfig = figure;
    set(STATSfig, 'Name', 'Frame stats over time');
    set(STATSfig, 'Units', 'Normalized');
    set(STATSfig, 'Position', [0.1 0.1 0.8 0.6]);
    statstemp = [min_lum mean_lum median_lum mode_lum];
    yaxis_limits = [min(min_lum(:))-1 max(statstemp(:))+1];
    for k = 1:length(sorted_channelid)
        figure(STATSfig);
        subplot(2,6,k);
        hold on;
            plot(t, min_lum(:,k), 'r');
            plot(t, mean_lum(:,k), 'k');
            plot(t, median_lum(:,k), 'b');
            plot(t, mode_lum(:,k), 'g');
%             plot(t, max_lum(:,k), 'r');
        hold off;
        set(gca, 'YLim', yaxis_limits);
        title(['Channel ' num2str(sorted_channelid(k))]);
        xlabel('time [s]');
        ylabel('Pixel Value');
        if k==6
            legend('min', 'mean', 'median', 'mode', 'Location', 'EastOutside');
        end
    end
    
    COLfig = figure;
    set(COLfig, 'Name', 'Average column per frame over time');
    set(COLfig, 'Units', 'Normalized');
    set(COLfig, 'Position', [0.1 0.1 0.8 0.6]);    
    for k = 1:length(sorted_channelid)
        figure(COLfig);
        subplot(2,6,k);
        imagesc(time(1:imgClip), 1:npx_vert, mean_columns(:,1:imgClip,k), colCLim); 
        colormap(hot);
        title(['Channel ' num2str(sorted_channelid(k))]);
        xlabel('time [s]');
        ylabel('avg(col) over time');
        if k==6
            colorbar;
        end
    end
    
    ROWfig = figure;
    set(ROWfig, 'Name', 'Average row per frame over time');
    set(ROWfig, 'Units', 'Normalized');
    set(ROWfig, 'Position', [0.1 0.1 0.8 0.6]);    
    for k = 1:length(sorted_channelid)
        figure(ROWfig);
        subplot(2,6,k);
        imagesc(1:npx_horz, time(1:imgClip), mean_rows(1:imgClip,:,k),rowCLim); 
        colormap(hot);
        title(['Channel ' num2str(sorted_channelid(k))]);
        xlabel('avg(row) over time');
        ylabel('time [s]');
        if k==6
            colorbar;
        end
    end
       
    FFTfig = figure;
    set(FFTfig, 'Units', 'Normalized');
    set(FFTfig, 'Position', [0.1 0.1 0.8 0.6]);    
    for k=1:length(sorted_channelid)
        figure(FFTfig);
        subplot(2,6,k);
        plot(f,magY(:,k)); 
        axis([0 20 0 max(magY(:))]);
        title(['Channel ' num2str(sorted_channelid(k))]);
        xlabel('Frequency (Hz)')
        ylabel('|Y(f)|');
    end
    
return;