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
        save_evtfile(filelist(k).name, d, 'm', mycalibum);
    end
    
    
%     mymsd = video_msd(d, window, metadata.instr.fps_imagingmode, mycalibum, 'no');        
%     myve  = ve(mymsd, bead_radius, freqtype, 'no');
    
% % %         if findstr(mode, 'd')            
% % %             save_evtfile(filelist(k).name, d, 'm', mycalibum);
% % % %             save_msdfile(filelist(k).name, mymsd);
% % % %             save_gserfile(filelist(k).name, myve);
% % %         end                
    
   
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
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_analyze_PMExpt: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    
