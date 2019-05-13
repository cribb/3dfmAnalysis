function ba_workflow(exptdir)
% 
%
% Given an experiment directory of bin files, perform automated analysis
% for a bead adhesion experimental protocol run on the Ixion tilting
% microscope in the Superfine lab.
%
% Inputs:
%    exptdir- directory of bin files
% 

if nargin < 1 || isempty(exptdir)
    error('No experiment directory defined.');
end

startdir = pwd;

exptdir = dir(exptdir);

if isempty(exptdir)
    error('Experiment directory not found.');
else
    exptdir = exptdir.folder;
end

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
    
%     disp('Converting bin file to stack of pgms...')
%     ba_bin2stack(binfile, [], true);
    
%     disp('Creating mini-video of each stack using MP4 format
%     ba_minivideo(stackdir);
    
    disp('Tracking beads in this stack...');
    ba_trackstack(stackdir);

%     disp('Copying the first frame (used for first locating beads).');
%     ba_copyfirstframe(stackdir);
    
%     disp('Compressing stack into smaller zip file.');
%     ba_zipstack(stackdir);
    
%     disp('Deleting stack...');
%     rmdir(stackdir, 's');
    
%     disp('Deleting original bin file...');
%     delete(binfile);
    
    % Return to our original experiment directory
    cd(exptdir);
        
end

cd(startdir);

return

    
