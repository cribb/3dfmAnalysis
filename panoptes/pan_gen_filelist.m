function outfl = pan_gen_filelist(metadata, wells, passes)
%

if nargin < 3 || isempty(passes) 
    passes = unique(metadata.pass_list)';
end
   
if nargin < 2 || isempty(wells)
    wells = unique(metadata.well_list)';
end

% % if ischar(wells)    
% %     filtparam_name = wells;
% %     filtparam      = evalin('caller', filtparam_name);    
% %     
% %     paramlist = unique(filtparam);
% %       % filter out empty strings 
% %       paramlist = paramlist( ~strcmp(paramlist, '') );
% % end

count = 1;
for p = 1:length(passes)
    for w = 1:length(wells)
        mypass = passes(p);
        mywell = wells(w);
        
        root_filestring = [metadata.instr.experiment ...
                          '_video' ...
                          '_pass' num2str(mypass) ...
                          '_well' num2str(mywell) ...
                          '_TRACKED'];
         
        file_type = '.vrpn.evt.mat';
        
        my_filename = [root_filestring file_type];
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