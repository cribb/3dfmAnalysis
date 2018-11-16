function v = bead_adhesion_workflow(exptdir)
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

starting_dir = pwd;

exptdir = dir(exptdir);
exptdir = exptdir.folder;

cd(exptdir);

binfiles = dir('*.bin');

B = length(binfiles);

if isempty(binfiles)
    error('No bin files found.');
end

% Set up Spot Tracker configuration. Should use a configuration file that
% is specific to each system/computer, but this will do for now. Function
% is at the end of this file.
vcfg = vst_config_init;   % Initialize with system specific info
vcfg.logdir = exptdir;    % Add on run/experiment specific info

for b = 1:B
    bname = binfiles(b).name;
    fpath = binfiles(b).folder;
    
    binbase = strrep(bname, '.bin', '');
    
    [status, msg, msgID] = mkdir(binbase);
    
%     bin2pgm(binfiles(b).name, binbase, false);
    
    cd(binbase);
    
    filestart = [fpath filesep binbase filesep 'frame00001.pgm'];
    
    % Spot Tracker will add the .vrpn and .csv file extensions
    vcfg.logname = join([vcfg.logdir, filesep, binbase], '');
    vst_run_from_matlab(filestart, vcfg);
    
end
    
cd(starting_dir);

v = 0;

return

    
