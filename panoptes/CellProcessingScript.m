function CellProcessingScript(filemask, frameRate, minFrames, minPixels, tcrop, xycrop)

if nargin < 6 || isempty(xycrop)
    xycrop = 0;
end

if nargin < 5 || isempty(tcrop)
    tcrop = 0;
end

if nargin < 4 || isempty(minPixels)
    minPixels = 0;
end

if nargin < 3 || isempty(minFrames)
    minFrames = 30;
end

if nargin < 2 || isempty(framerate)
    framerate = 54;
end

if nargin < 1 || isempty(filemask)
    filemask = '*.vrpn.mat';
end

window =  [1:10 20:20:100 100:30:250 300];
calibum = 0.152;

plotMean = 1; %Set to 1 to plot means; set to 0 to plot each tracker

% attach timescales and handle filtering 
files = SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels, tcrop, xycrop)

%% Find all the .vrpn files and extract well number from filename
% files = dir('*vrpn.evt.mat');
filenamesCell = {files.name}';
wellNumIDX = 5+cell2mat(strfind(filenamesCell, '_well'));
filenames = strvcat(filenamesCell);
numFiles = length(files);

wellID = nan(numFiles,1);
for i = 1:numFiles
    thisStr = filenames(i,wellNumIDX(i):end);
    dotIDX = findstr(thisStr, '.');
    thisStr = thisStr(1:dotIDX(1)-1);
    wellID(i) = str2num(thisStr);
end

%% Calculate MSD for each tracking file and store in its own structure
wellList = unique(wellID);
d = [length(window) 0]; %init size of msd. Need this to avoid problems with number of rows across videos
for i = 1:numFiles
    thisMSD = video_msd(cell2mat(filenamesCell(i)), window, [], calibum, 'no');
    DATA(i).well = wellID(i);
    DATA(i).tau  = thisMSD.tau;
    DATA(i).msd  = thisMSD.msd;
    d = min([d ; size(thisMSD.msd)]);
end
for i = 1:numFiles
    DATA(i).tau = DATA(i).tau(1:d(1),:);
    DATA(i).msd = DATA(i).msd(1:d(1),:);
end
tau = DATA(1).tau(:,1);

%% Plot mean MSDs
figure;
hold on
colors = colormap('lines');
for i = 1:length(wellList)
    % Combine MSDs from all trackers in this well
    vidsInThisWell = find([DATA.well] == wellList(i));
    msd = [DATA(vidsInThisWell).msd] .* 10^12;
    % Average across trackers
    msdMean = nanmean(msd, 2);
    
    % Get standard error
    [numTau, numTrackers] = size(msd);
    msdErr  = nanstd(msd,0,2) ./ sqrt(numTrackers);
    if (plotMean)
        errorbar(tau,msdMean,msdErr, 'Color', colors(i,:));
    elseif(~plotMean)
        plot(tau,msd, 'Color', colors(i,:));
    end
end
set(gca, 'XScale', 'Log', 'YScale', 'Log');
xlabel('\tau (s)');
ylabel('<r^2> (\mum^2)')
box on
legend(num2str(wellList), 'Location', 'NorthWest');
hold off