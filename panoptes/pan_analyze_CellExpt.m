function outs = pan_analyze_CellExpt(filemask)

outs = 0;

return;


% % % % input files   
% % % if nargin < 1 || isempty(filemask)
% % %     filemask = '*.vrpn.mat';
% % % end
% % % 
% % % % video file metadata
% % % frame_rate = 54;
% % % calibum = 0.152;
% % % 
% % % % filter settings
% % % min_frames = 30;
% % % min_pixels = 0;
% % % tcrop = 0;
% % % xycrop = 0;
% % % 
% % % % msd analysis settings
% % % window =  [1:10 20:20:100 100:30:250 300];
% % % 
% % % % output Report settings
% % % plotMean = 1; %Set to 1 to plot means; set to 0 to plot each tracker
% % % 
% % % filelist = dir(filemask);
% % % 
% % % for k = 1:length(filelist)
% % %     filename = files(k).name;
% % % 
% % %         filt.min_frames = minFrames;
% % %     filt.min_pixels   = minPixels;   % maxPixelRange ??
% % %     filt.tcrop = tcrop;
% % %     filt.xycrop = xycrop;
% % % 
% % %     %fprintf('Loading %g of %g \n', i, length(files));
% % %     d = load_video_tracking(filename, frame_rate, [], [], 'absolute', 'no', 'table');
% % %     d = filter_video_tracking(d, filt);
% % % 
% % %     if(~isempty(d))
% % %         tracking.spot3DSecUsecIndexFramenumXYZRPY = d;
% % % 
% % %         fprintf('\t%g trackers in ', length(unique(d(:,ID))));
% % %         fprintf(filename);
% % % 
% % %         append = 'evt.mat';
% % %         outfile = [filename(1:end-3) append];
% % %         save(outfile, 'tracking');
% % %     else
% % %         fprintf('No trackers. No .evt.mat created.');
% % %     end
% % %     fprintf('\n');
% % % end
% % % 
% % % % analysis protocol
% % % 
% % % d = filter_video_tracking(d, min_frames, min_pixels, tcrop, xycrop);
% % % 
% % % 
% % % %% Find all the .vrpn files and extract well number from filename
% % % files = dir('*vrpn.evt.mat');
% % % filenamesCell = {files.name}';
% % % wellNumIDX = 5+cell2mat(strfind(filenamesCell, '_well'));
% % % filenames = strvcat(filenamesCell);
% % % numFiles = length(files);
% % % 
% % % wellID = nan(numFiles,1);
% % % for i = 1:numFiles
% % %     thisStr = filenames(i,wellNumIDX(i):end);
% % %     dotIDX = findstr(thisStr, '.');
% % %     thisStr = thisStr(1:dotIDX(1)-1);
% % %     wellID(i) = str2num(thisStr);
% % % end
% % % 
% % % %% Calculate MSD for each tracking file and store in its own structure
% % % wellList = unique(wellID);
% % % d = [length(window) 0]; %init size of msd. Need this to avoid problems with number of rows across videos
% % % for i = 1:numFiles
% % %     thisMSD = video_msd(cell2mat(filenamesCell(i)), window, [], calibum, 'no');
% % %     DATA(i).well = wellID(i);
% % %     DATA(i).tau  = thisMSD.tau;
% % %     DATA(i).msd  = thisMSD.msd;
% % %     d = min([d ; size(thisMSD.msd)]);
% % % end
% % % for i = 1:numFiles
% % %     DATA(i).tau = DATA(i).tau(1:d(1),:);
% % %     DATA(i).msd = DATA(i).msd(1:d(1),:);
% % % end
% % % tau = DATA(1).tau(:,1);
% % % 
% % % %% Plot mean MSDs
% % % figure;
% % % hold on
% % % colors = colormap('lines');
% % % for i = 1:length(wellList)
% % %     % Combine MSDs from all trackers in this well
% % %     vidsInThisWell = find([DATA.well] == wellList(i));
% % %     msd = [DATA(vidsInThisWell).msd] .* 10^12;
% % %     % Average across trackers
% % %     msdMean = nanmean(msd, 2);
% % % 
% % %     % Get standard error
% % %     [numTau, numTrackers] = size(msd);
% % %     msdErr  = nanstd(msd,0,2) ./ sqrt(numTrackers);
% % %     if (plotMean)
% % %         errorbar(tau,msdMean,msdErr, 'Color', colors(i,:));
% % %     elseif(~plotMean)
% % %         plot(tau,msd, 'Color', colors(i,:));
% % %     end
% % % end
% % % set(gca, 'XScale', 'Log', 'YScale', 'Log');
% % % xlabel('\tau (s)');
% % % ylabel('<r^2> (\mum^2)')
% % % box on
% % % legend(num2str(wellList), 'Location', 'NorthWest');
% % % hold off