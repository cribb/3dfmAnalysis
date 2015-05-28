function check_moving_or_stuck(filename,type)
% filename is the base movie name; it does not contain ' (Moving)' or 
% ' (Stuck)' at the end, nor does it contain the file extension; type = 1
% for moving, 2 for stuck

% HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (note didn't keep track of changes before this)
% 06/18/13: changed to handle IDL instead of VST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MODIFY THESE PARAMETERS AS NEEDED
conversion = 0.156; % Doesn't really matter what value, since we just need XY in pixels
frame_rate = 15; % frames/sec
min_frames = 50;
duplicate_cutoff = 0;
sheetname = 'Sheet3'; % Sheet3 for IDL
file_extension = '.xlsx'; % This is the typical output format for MPT_combined_v2, but change to '.xls' if needed
if type == 1
    type_extension = ' (Moving)';
else type_extension = ' (Stuck)';
end

% csv_filename = [filename type_extension '.tif.csv'];
% VST_data = csvread(csv_filename,1,0);
% MPT_data = [VST_data(:,2) VST_data(:,1) VST_data(:,3:4)];
% [~,z] = sort(MPT_data(:,1));
% MPT_data = MPT_data(z,:);

excel_filename = [filename type_extension '.xlsx'];
MPT_data = xlsread(excel_filename); % Should have correct formatting already with particle, frame, X, Y
[~,z] = sort(MPT_data(:,1));
MPT_data = MPT_data(z,:);

Excel_filename = [filename type_extension file_extension];
xlswrite(Excel_filename,MPT_data);

MPT_combined_v2(Excel_filename,sheetname,conversion,frame_rate,min_frames,duplicate_cutoff)
if type == 1
    B = xlsread(Excel_filename,'XY Moving'); % XY for moving particles
else B = xlsread(Excel_filename,'XY Stuck'); % XY for stuck particles
end

% Re-number particles
frames = [];
j= 1; % frames counter
k = 0; % particle counter
for i = 2:length(B(:,1));
    if B(i,1) == B(i-1,1) && B(i,2) == B(i-1,2)+1 % Still same particle
        j = j+1;
    else % New particle starts
        B((sum(frames)+1):i-1,1) = k+1; % Assign preceding frames to particle #
        frames = [frames j];
        k = k+1;
        j = 1;
    end
    if i == length(B(:,1)) % Last particle
        B((sum(frames)+1):end,1) = k+1; % Assign preceding frames to particle #
        frames = [frames length(B((sum(frames)+1):end,1))];
        k = k+1;
    end
end
num_particles = k;

movie_filename = [filename '.tif'];
movieinfo = imfinfo(movie_filename);

% Make movie with trajectories overlayed (note: much of code borrowed from
% Benjamin Schuster)
num_images = numel(movieinfo);
% Read first frame for size info
a = double(imread(movie_filename, 1, 'Info', movieinfo)); %'Info' speeds imread for multi-image tiff
[m,n] = size(a);
aviobj = avifile([filename type_extension '.avi'],'fps',frame_rate,'compression','none');
colors = jet(num_particles); %rand(particles,3)
f = figure('Units','pixels','Position',[150 150 n m],'visible','off');
ax1 = axes('Parent',f,'Position',[0 0 1 1],'units','normalized');
set(ax1,'XLim',[0 n],'YLim',[0 m],'YDir','reverse','visible','off');
ax2 = axes('Parent',f,'Position',[0 0 1 1],'units','normalized');
set(ax2,'XLim',[0 n],'YLim',[0 m],'YDir','reverse','visible','off');
for i = 1:num_images
    cla(ax1)
    cla(ax2)
    A = imread(movie_filename, i, 'Info', movieinfo);
    a = double(A);
    im = imagesc('Parent',ax1,'CData',a,'AlphaData',1);
    colormap(ax1,'gray')
    hold(ax1,'on')
%     for r = 1:num_regions_to_subtract(mvnum)
%         plot(roiVerticesX{mvnum}{r},roiVerticesY{mvnum}{r},'color','r','Parent',ax1)
%     end

    %there are more efficient ways to do this, but they did not make the
    %code run faster
    for j = 1:num_particles
        trajFrames = B(B(:,1) == j,2);
        if type == 1 % Moving
            x = B(B(:,1) == j,3);
            y = B(B(:,1) == j,4);
        else
            x = mean(B(B(:,1) == j,3));
            y = mean(B(B(:,1) == j,4));
            r = 5; % Radius of circle to draw
            theta = [0:pi/10:2*pi]';
            x = x + r*cos(theta);
            y = y + r*sin(theta);
        end

        p = 1:length(x);
        if i >= trajFrames(1) && i <= trajFrames(end)
            pa = patch([x' NaN],[y' NaN],[p NaN],'EdgeColor',colors(j,:),'EdgeAlpha',0.5,'Parent',ax2);
        elseif i > trajFrames(end)
            pa = patch([x' NaN],[y' NaN],[p NaN],'EdgeColor',[1 1 1],'EdgeAlpha',0.5,'Parent',ax2);
        end
    end
    aviobj = addframe(aviobj,f);
    if mod(i,50)==0
        disp(['frame ' num2str(i) ' done'])
    end
end
aviobj = close(aviobj);