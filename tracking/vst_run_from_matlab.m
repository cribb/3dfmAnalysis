function v = vst_run_from_matlab(filetotrack, ins)

filetotrack = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\sample_video\MucusBeads1\frame00001.pgm';

ins.VSTdir = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.13.0\';
ins.VSTcuda = 'video_spot_tracker_local.bat';
ins.VSTexe = 'video_spot_tracker.exe';
% ins.VSTexe = 'video_spot_tracker_nogui.exe';
ins.burstimage = '';
ins.firstframe = '';
ins.absfile = '';
ins.configFind = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\optimize_z_test.cfg';
ins.configTrack = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\optimize_z_test.cfg';
ins.os = '';
ins.logdir = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\';

tclpath = join([ins.VSTdir, 'tcl8.3'], '');
 tkpath = join([ins.VSTdir, 'tk8.3'], '');
command = join([ins.VSTdir, filesep, ins.VSTexe], '');
logfile = join([ins.logdir, 'test_tmp'], '');

commandopts = ['-enable_internal_values ' ...
               '-lost_all_colliding_trackers ' ...
               '-load_state "' ins.configFind '" ' ...
               '-tracker 0 0 50 ' ...
               '-outfile "' logfile '" ' ...
               '"' filetotrack '" '];
           
fullcommand = ['"' command '" ' commandopts];
systemSTR = join(fullcommand);
disp(systemSTR);

% setenv('PATH', mypath);
setenv('TCL_LIBRARY', tclpath);
setenv('TK_LIBRARY', tkpath);


cd(ins.VSTdir);
system(systemSTR);

return
 
% 
% function v = create_vstbat(ins)
% 
% 
% 
% cmd = ".\video_spot_tracker.exe";
% 
% fprintf('set PATH=%s;\%PATH\% \n',mypath);
% fprintf('set TCL_LIBRARY=%s\n', tclpath);
% fprintf('set TK_LIBRARY=%s\n', tkpath);
% 
% % REM By default, call the non-CUDA version of spot tracker.
% fprintf('set CMD="%s"\n', cmd);
% 
% % REM If the first command-line argument is CUDA, then set the command name to run the
% % REM CUDA version and shift the command-line arguments to remove it from the ones sent
% % REM to the command we call.
% % IF NOT [%1]==[CUDA] GOTO NOCUDA
% % set CMD=".\video_spot_tracker_CUDA.exe"
% % SHIFT
% % :NOCUDA
% % 
% fprintf('\%CMD\% \%1 \%2 \%3 \%4 \%5 \%6 \%7 \n');
% 
% % if not errorlevel 0 pause
