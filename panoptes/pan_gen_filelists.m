function outfl = pan_gen_filelists(filepath, systemid, plate_type)
% PAN_GEN_FILELISTS generate and check list of panoptes data files
%
% Generates lists of files expected from a Panoptes run's wells.txt file
% and checks against what's present and reports on what's missing.
%

metadata = pan_load_metadata(filepath, systemid, plate_type);

Wells_txt_file   = [metadata.instr.experiment ...
                    '_ExperimentConfig' ... % + some timestamp
                    ];

Layout_file      = '*_WELL_LAYOUT.csv';

MCU_file         = [metadata.instr.experiment ...
                    '_MCUparams.txt'];

findcfg_file     = [];
trackcfg_file    = [];
        
exptname = metadata.instr.experiment;

pass_list = 1:size(metadata.instr.offsets,1);
well_list = metadata.instr.wells;

fidmax = length(pass_list) * length(well_list);

count = 1;
for p = 1:length(passes)
    for w = 1:length(wells)
        mypass = passes(p);
        mywell = wells(w);



        
        burst_filestring = [metadata.instr.experiment ...
                           '_Flburst' ...
                           '_pass' num2str(mypass) ...
                           '_well' num2str(mywell)];        
        video_filestring = [metadata.instr.experiment ...
                           '_video' ...
                           '_pass' num2str(mypass) ...
                           '_well' num2str(mywell) ...
                           '_TRACKED'];
                       
%         vrpnmat_file
%         trackcsv_file
%         vrpnevt_file      

        file_type = '.vrpn.evt.mat';
        
        my_filename = [video_filestring file_type];
        q = dir( my_filename );
              
        if ~isempty(q)
            outfl(count) = q;
            count = count + 1;
        else
            logentry(['Filename: ' my_filename ' was not found.']);
        end
    end
end

if ~exist('outfl');
    outfl = [];
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
     headertext = [logtimetext 'pan_gen_filelist: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;