function ba_workflow(filemask)
% 
%
% Given an experiment directory of bin files, perform automated analysis
% for a bead adhesion experimental protocol run on the Ixion tilting
% microscope in the Superfine lab.
%
% Inputs:
%    exptdir- directory of bin files
% 

if nargin < 1 || isempty(filemask)
    error('No files to work on.');
end

filelist = dir(filemask); 

if isempty(filelist)
    error('This directory does not contain files in filemask.');
end

exptdir = filelist(1).folder;

startdir = pwd;
cd(exptdir);

binfilelist = dir('**/*.bin');

if isempty(binfilelist)
    %error('No bin files found.');
end

B = length(binfilelist);

% For every .bin file in my experiment directory
for b = 1:B
    
    binfile = binfilelist(b).name;
    binpath = binfilelist(b).folder;    
    binbase = strrep(binfile, '.bin', '');
    
    stackdir = [binpath, filesep, binbase];
    
    cd(binpath);
    
    logentry('Converting bin file to stack of pgms...')
    ba_bin2stack(binfile, [], true);

    logentry('Loading frame extraction times and motor z-positions');
    tz = load([stackdir '.meta.mat']);
    
    logentry('Retrieving first & last frames (used for first locating beads).');
    ba_copyfirstframe(stackdir);
    
    logentry('Creating mini-video of stack using MP4 format');
    ba_minivideo(stackdir);
    
    logentry('Tracking beads in this stack...');
    ba_trackstack(stackdir);

    logentry('Deleting original bin file...');
    delete(binfile);

%     logentry('Finding beads in first and last frames.');
%     ba_discoverbeads(
%     logentry('Compressing stack into smaller zip file.');
%     ba_zipstack(stackdir);
    
%     logentry('Deleting stack...');
%     rmdir(stackdir, 's');
    

    
    % Return to our original experiment directory
    cd(exptdir);
        
end

cd(startdir);

return

    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ba_workflow: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  