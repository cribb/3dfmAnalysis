function [msds paramlist] = pan_combine_data(metadata, filtparam_name)

video_tracking_constants;

if nargin < 2 || isempty(filtparam_name)
    filtparam_name = 'well';
    filtparam = 1;
else 
    filtparam = evalin('caller', filtparam_name);
end

logentry(['Aggregating across ' filtparam_name]);

% other parameter settings
plate_type = '96well';
window = 35;
freqtype = 'f';

if isnumeric(filtparam)
    filtparam = cellstr(num2str(filtparam));
end

welllist = metadata.well_list;
paramlist = unique(filtparam);
  % filter out empty strings 
  paramlist = paramlist( ~strcmp(paramlist, '') );

% paramlist = paramlist{~isempty(paramlist)};
mystring = [];
for k = 1:length(paramlist)
    mystring = [mystring paramlist{k} '  '];
end

logentry(['Parameter *' filtparam_name '* has ' num2str(length(paramlist)) ' members:  ' mystring ]);

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

    filelist = pan_gen_filelist(metadata, wells_to_combine, []);
        
    for m = 1 : length(filelist)

        myfile = filelist(m).name;
        [mywell mypass] = pan_wellpass( myfile );

        myMCU(m) = metadata.mcuparams.mcu(metadata.mcuparams.well == mywell & ...
                                          metadata.mcuparams.pass == mypass );
    end

    mycalibum = pan_MCU2um(myMCU);                               

    bead_radius = str2double(metadata.plate.bead.diameter(mywell)) * 1e-6 / 2;

    d = load_video_tracking(filelist, ...
                        metadata.instr.fps_bright, ...
                        'm', mycalibum, ...
                        'absolute', 'no', 'table');                                        

    mymsd = video_msd(d, window, metadata.instr.fps_bright, mycalibum, 'no');                
    msds(p) = msdstat(mymsd);
    
    myve(p)  = ve(mymsd, bead_radius, freqtype, 'no');

    clear myMCU;  

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
     headertext = [logtimetext 'pan_combine_data: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;