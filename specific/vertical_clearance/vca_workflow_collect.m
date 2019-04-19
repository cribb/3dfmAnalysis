function vca_workflow_collect(exptdir)
% 
%
% Given an experiment directory of bin files, perform automated analysis
% for a bead adhesion experimental protocol run on the Ixion tilting
% microscope in the Superfine lab.
%
% Inputs:
%    exptdir- directory of bin files

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
    
    % Convert .bin file to stack of pgms
    ba_bin2stack(binfile);
    
    % Create a mini-video of each stack using MP4 format
    ba_minivideo(stackdir);
    
    % Track the beads in each stack
    ba_trackstack(stackdir);

    % Copy the firstframe and give it an expected filename
    ba_copyfirstframe(stackdir);
    
    % Compress each stack into a zip file for later use if necessary
    ba_zipstack(stackdir);
    
    % Delete the stack
%     rmdir(stackdir, 's');
    
    % Delete the bin file
%     delete(binfile);
    
    % Return to our original experiment directory
    cd(exptdir);
        
end

cd(startdir);

return

    
