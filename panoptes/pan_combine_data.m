function [msds paramlist] = pan_combine_data(metadata, filtparam_name)
% PAN_COMBINE_DATA  Combines necessary data to analyze for a Panoptes experiment
%
% CISMM function
% Panoptes
%  
% Determines which files/datasets to combine in order to analyze a Panoptes 
% experiment.  This function is intended to be used for any experiment 
% (so far) described and ran by PanopticNerve.
% 
%  pan = panoptes_combine_data(metadata, filtparam_name) 
%   
%  "metadata" is the matlab structure that describes a Panoptes experiment
%  design, outputted by 'pan_load_metadata'
%  "filtparam_name" is a string that identifies the content over which the
%  data need to be combined.  The default value is 'well'
%  "msds" contains the outputted mean square displacement data
%  "paramlist" 
%

video_tracking_constants;

systemid = metadata.instr.systemid;

if nargin < 2 || isempty(filtparam_name)
    filtparam_name = 'metadata.plate.well_map';
    filtparam = 1;
else 
    filtparam = evalin('caller', filtparam_name);
end

logentry(['Aggregating across ' filtparam_name]);

% other parameter settings
plate_type = '96well';

window = metadata.window;

freqtype = 'f';

if isnumeric(filtparam)
    filtparam = cellstr(num2str(filtparam));
end

welllist = metadata.well_list;
paramlist = unique(filtparam);

  % filter out empty strings 
  paramlist = paramlist( ~strcmp(paramlist, '') );

% Put together a list of aggregating members and output that to the console for
% debugging purposes
mystring = [];
for k = 1:length(paramlist)
    mystring = [mystring paramlist{k} '  '];
end

logentry(['Parameter *' filtparam_name '* has ' num2str(length(paramlist)) ' members:  ' mystring ]);

% Iterate over the aggregating members
for p = 1:length(paramlist)

    switch filtparam_name
        case 'well'
            uniqwell = unique(welllist)';
        otherwise
            myparam = paramlist{p};
            if ~isempty(myparam)
                wells_to_combine = strcmp(myparam, filtparam);
                wells_to_combine = find(wells_to_combine > 0);
            else 
                continue;
            end
    end

    % Generate the list of files that need to be loaded and combined into
    % an aggregate dataset.w
    filelist = pan_gen_filelist(metadata, wells_to_combine, []);
    
    my_well_list = [];
    
    if ~isempty(filelist)
        for m = 1 : length(filelist)

            myfile = filelist(m).name;
            [mywell mypass] = pan_wellpass( myfile );

            thisMCU = metadata.mcuparams.mcu(metadata.mcuparams.well == mywell & ...
                                             metadata.mcuparams.pass == mypass );
                                         
            my_well_list(m) = mywell;
            
            if ~isempty(thisMCU)
               myMCU(m) = thisMCU;
            else
               myMCU(m) = NaN;
            end
        end
        
        bead_radius = str2double(metadata.plate.bead.diameter(mywell)) * 1e-6 / 2;
    else
        myMCU = NaN;
        my_well_list = NaN;
        bead_radius = NaN;
    end
    
    mycalibum = pan_MCU2um(myMCU, systemid, my_well_list);

        
        

        [d, calout] = load_video_tracking(filelist, ...
                            metadata.instr.fps_imagingmode, ...
                            'm', mycalibum, ...
                            'absolute', 'no', 'table');                                        

%         if calout ~= mycalibum 
%             error('Loaded calibration value does note equal determined value.');
%         end
        
        % so any aggregated_data files need to use 0.152 as the conversion for
        % microns to pixels, as the initial scaling of pixel to micron occurred
        % via a video-by-video and MCUparameter basis.
        save_evtfile(['aggregated_data_' myparam], d, 'm', 0.152);

        mymsd = video_msd(d, window, metadata.instr.fps_imagingmode, mycalibum, 'no');                

        msds(p) = msdstat(mymsd);        
        myve(p)  = ve(mymsd, bead_radius, freqtype, 'no');

        clear myMCU;  
%     else
%         logentry('No data for this set.  No video found.');
%         mymsd = 
%         msds(p) = msdstat([]);
%         myve(p) = ve([]);        
%     end

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
     headertext = [logtimetext 'pan_combine_data: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;