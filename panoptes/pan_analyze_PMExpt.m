function outs = pan_analyze_PMExpt(filepath, filt, systemid)

if ~exist('filepath', 'var'), filepath= []; end;
if ~exist('filt', 'var'), filt = []; end;
if ~exist('mode', 'var'), mode = []; end;
    
% other parameter settings
plate_type = '96well';
freqtype = 'f';

[filepath, filt, mode] = check_params(filepath, filt, mode);

metadata = pan_load_metadata(filepath, systemid, plate_type);

logentry('Loaded metadata');

    if isempty(metadata)
        logentry('No or insufficient metadata.  Cannot run analysis.  Exiting now...');
        outs = [];
        return;
    end

    
% if there are no 'evt' files then no filtering/editing has happened so
% we'll filter now according to the values set in the filt structure
% (defined in the help text for filter_video_tracking)
if length(metadata.files.evt) == length(metadata.files.tracking)
    filelist = metadata.files.evt;
else
    filelist = metadata.files.tracking;
end


for k = 1:length(filelist)
    
    myfile = filelist(k).name;
    [mywell mypass] = pan_wellpass( myfile );
    
    myMCU = metadata.mcuparams.mcu(metadata.mcuparams.well == mywell & ...
                                   metadata.mcuparams.pass == mypass );
                               
%     metadata.filt.xyzunits = 'm';
    mycalibum = pan_MCU2um(myMCU);

    bead_radius = str2double(metadata.plate.bead.diameter(mywell)) .* 1e-6 ./ 2;
    
%     logentry(['Loading ' filelist(k).name]);
    
    filt.xyzunits    = 'm';
    filt.calib_um    = mycalibum;
    filt.bead_radius = bead_radius;

    d = load_video_tracking(filelist(k).name, ...
                            metadata.instr.fps_imagingmode, ...
                            'm', mycalibum, ...
                            'absolute', 'no', 'table');
                       
    % only have to filter if we need to process .vrpn.mat to .vrpn.evt.mat
    if length(metadata.files.evt) ~= length(metadata.files.tracking)
        d = filter_video_tracking(d, filt);
    end
    
    
%     mymsd = video_msd(d, window, metadata.instr.fps_imagingmode, mycalibum, 'no');        
%     myve  = ve(mymsd, bead_radius, freqtype, 'no');
    
        if findstr(mode, 'd')            
            save_evtfile(filelist(k).name, d, 'm', mycalibum);
%             save_msdfile(filelist(k).name, mymsd);
%             save_gserfile(filelist(k).name, myve);
        end                
    
   
%     
end

outs = 0;

return;


function [filepath, filt, mode] = check_params(filepath, filt, mode)

    if nargin < 3 || isempty(mode)
        mode = 'd';
    end

%     if nargin < 2 || isempty(filt) || ~isfield(filt, 'frame_rate')
%         filt.frame_rate = 54;
%     end

    if nargin < 2 || isempty(filt) || ~isfield(filt, 'min_frames')
        filt.min_frames = 15;
    end

    if nargin < 2 || isempty(filt) || ~isfield(filt, 'min_pixels')
        filt.min_pixels = 0;
    end

    if nargin < 2 || isempty(filt) || ~isfield(filt, 'tcrop')
        filt.tcrop = 0;
    end

    if nargin < 2 || isempty(filt) || ~isfield(filt, 'xycrop')
        filt.xycrop = 1;
    end

    if nargin < 1 || isempty(filepath)
        filepath = '.';
    end

    return;
    
    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_analyze_PMExpt: '];
     
     fprintf('%s%s\n', headertext, txt);
     
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