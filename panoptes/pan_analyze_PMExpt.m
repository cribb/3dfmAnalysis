function outs = pan_analyze_PMExpt(filepath, filt, systemid)

if ~exist('filepath', 'var'), filepath= []; end;
if ~exist('filt', 'var'), filt = []; end;
if ~exist('systemid', 'var'), systemid = []; end;

video_tracking_constants;

% other parameter settings
plate_type = '96well';
freqtype = 'f';

[filepath, filt, systemid] = check_params(filepath, filt, systemid);

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

    
    mycalibum = pan_MCU2um(myMCU, systemid, mywell);


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
        [d, filtout] = filter_video_tracking(d, filt);

        if isfield(filtout, 'drift_vector') 
                drift_vectors.pass(k,1) = mypass;
                drift_vectors.well(k,1) = mywell;

                if ~isempty(filtout.drift_vector)
                    drift_vectors.xvel(k,1) = filtout.drift_vector(1,1);
                    drift_vectors.yvel(k,1) = filtout.drift_vector(1,2);
                else
                    drift_vectors.xvel(k,1) = NaN;
                    drift_vectors.yvel(k,1) = NaN;
                end
        end
        
        if isfield(filtout, 'num_jerks') 
            jerk_report.pass(k,1) = mypass;
            jerk_report.well(k,1) = mywell;

            if ~isempty(filtout.num_jerks)
                jerk_report.num_jerks(k,1) = filtout.num_jerks;
            else
                jerk_report.num_jerks(k,1) = NaN;
            end
        end
        
        save_evtfile(filelist(k).name, d, 'm', mycalibum);        
    end
    
    % summarize the tracking information for each video
    if ~isempty(d)
        num_trackers = length(unique(d(:,ID)));
        tracker_with_longest_duration = mode(d(:,ID));
        longest_duration = max( d( d(:,ID) == tracker_with_longest_duration, FRAME));   
        summary.data(k,:) = [mypass mywell num_trackers tracker_with_longest_duration longest_duration];   
        summary.data = sortrows(summary.data, [1 2]);
        summary.headers = {'pass' 'well' 'number of trackers' 'tracker with longest duration' 'longest duration'};
        summary.units   = {'[]' '[]' '[]' '[]' 'frames'};
    end
    
% %     % plotting tracker availability
% %     travfig = figure('Visible','off'); 
% %     if ~isempty(d)
% %         plot_tracker_avail(d(:,FRAME), d(:,ID), travfig);
% %         tr_avail_file_temp = strrep(filelist(k).name, 'vrpn.mat', '');
% %         tr_avail_file_temp = strrep(tr_avail_file_temp, 'vrpn.evt.mat', '');    
% %         tr_avail_file{k} = [tr_avail_file_temp  'trav'];
% % 
% %         saveas(travfig, [tr_avail_file{k} '.png'], 'png');
% % %         gen_pub_plotfiles(tr_avail_file{k}, travfig, 'normal'); 
% %         close(travfig); 
% %     end
% %     
% %     % plot longest time,XY trace
% %     if ~isempty(d)
% %         tracker_list = unique(d(:,ID));
% %         txy_file_temp = strrep(filelist(k).name, 'vrpn.mat', '');
% %         txy_file_temp = strrep(tr_avail_file_temp, 'vrpn.evt.mat', '');    
% %         txy_file{k} = [tr_avail_file_temp  'txy'];
% % 
% %             longest_tracker = mode(tracker_list);
% %             LTidx = find(d(:,ID) == longest_tracker);
% %             this_trajectory = d(LTidx,:);
% % 
% %             x_px = ( this_trajectory(:,X) - this_trajectory(1,X) ) * 1e6 / calib_um;
% %             y_px = ( this_trajectory(:,Y) - this_trajectory(1,Y) ) * 1e6 / calib_um;
% %             
% %             XTfig = figure;
% %             plot(this_trajectory(:,TIME), [ x_px, y_px ], '.-');        
% %             xlabel('time [s]');
% %             ylabel('displacement [px]');
% %             legend('x', 'y');    
% %             set(XTfig, 'DoubleBuffer', 'on');
% %             set(XTfig, 'BackingStore', 'off');    
% %             drawnow;
% % 
% %             saveas(XTfig, [txy_file{k} '.png'], 'png');
% %             close(XTfig)
% %     end
    
  
    
%     mymsd = video_msd(d, window, metadata.instr.fps_imagingmode, mycalibum, 'no');        
%     myve  = ve(mymsd, bead_radius, freqtype, 'no');
    
% % %         if findstr(mode, 'd')            
% % %             save_evtfile(filelist(k).name, d, 'm', mycalibum);
% % %             save_msdfile(filelist(k).name, mymsd);
% % %             save_gserfile(filelist(k).name, myve);
% % %         end                
    
     
end

drift_filename = [metadata.instr.experiment '.drift.mat'];
if exist('drift_vectors', 'var')
    save(drift_filename, '-STRUCT', 'drift_vectors');
end

jerk_filename = [metadata.instr.experiment '.numjerks.mat'];
if exist('jerk_report', 'var')
    save(jerk_filename, '-STRUCT', 'jerk_report');
end

summary_filename = [metadata.instr.experiment '.tracking_summary.mat'];
if exist('summary', 'var')
    save(summary_filename, '-STRUCT', 'summary');
end
outs = 0;

return;


function [filepath, filt, systemid] = check_params(filepath, filt, systemid)

    if nargin < 3 || isempty(systemid)
        systemid = 'panoptes';
    end

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
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_analyze_PMExpt: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    
