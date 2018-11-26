function v = vst_run_from_matlab(filetotrack, logfile, configfile, ins)

% filetotrack = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\sample_video\MucusBeads1\frame00001.pgm';

if nargin < 3 || isempty(ins)
    error('Video Spot Tracker configuration empty or not found.');
end

if nargin < 1 || isempty(filetotrack) || ~exist(filetotrack, 'file')
    error('File empty or not found.');
end

startpath = pwd;

vst_check_config(ins);

% logfile = join([ins.logdir, 'test_tmp'], '');

commandopts = ['-enable_internal_values ' ...
               '-lost_all_colliding_trackers ' ...
               '-load_state "' configfile '" ' ...
               '-tracker 0 0 50 '];

if isfield(ins, 'continue_from')
    tmp = dir(ins.continue_from);
    disp(['Continuing from: ' tmp.name]);
    commandopts = [commandopts '-continue_from "' ins.continue_from '" '];
else
    disp('');
    disp('Initiating tracking: ');
end

if nargin < 2 || isempty(logfile)
    warning('No logfile defined.');
else
    commandopts = [commandopts ' -outfile "' logfile '" '];
end


commandopts = [commandopts '"' filetotrack '" '];

% disp(commandopts);     

copyfile([ins.VSTdir filesep 'russ_widgets.tcl'], startpath);
copyfile([ins.VSTdir filesep 'video_spot_tracker.tcl'], startpath);

% fullcommand = ['"' ins.command '" ' commandopts];
fullcommand = ['"' ins.VSTexe '" ' commandopts];

systemSTR = join(fullcommand);

oldpath = getenv('PATH');
if ~contains(oldpath, ins.VSTdir)
    newpath = [oldpath pathsep ins.VSTdir];
else
    newpath = oldpath;
end

% setenv('PATH', mypath);
setenv('TCL_LIBRARY', ins.tclpath);
setenv('TK_LIBRARY', ins.tkpath);
setenv('PATH', newpath);

% cd(ins.VSTdir);
disp(systemSTR);
% system(systemSTR);
% cd(startpath);

delete('russ_widgets.tcl');
delete('video_spot_tracker.tcl');

v = 0;

return
 



