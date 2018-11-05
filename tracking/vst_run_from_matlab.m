function v = run_vst_from_matlab(filename, configfile)

filetotrack = '\\nsrg\nanodata2\cribb\expts\mucus_adhesion_assay\MucusBeads1\frame00001.pgm';

ins.VSTdir = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.12.1\';
ins.VSTfile = 'video_spot_tracker.bat';
ins.burstimage = '';
ins.firstframe = '';
ins.absfile = '';
ins.configFind = 'D:\jcribb\optimize_z_test.cfg';
ins.configTrack = 'D:\jcribb\optimize_z_test.cfg';
ins.os = '';

envpath = getenv('PATH');
impath = 'C:\NSRG\external\pc_win32\bin\ImageMagick-5.5.7-Q16';
nsrgpath = 'C:\NSRG\external\pc_win32\bin\';
javapath = 'C:\Program Files (x86)\Java\jre7\bin\client';
mypath = [impath, ';', nsrgpath, ';', javapath, ';', envpath];

tclpath = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.12.1\tcl8.3';
 tkpath = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.12.1\tk8.3';

command = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.12.1\video_spot_tracker.exe';
outfile = 'D:\jcribb\test_tmp';

% commandopts = ['-enable_internal_values ' ...
%                '-lost_all_colliding_trackers ' ...
%                '-load_state "' ins.configFind '" ' ...
%                '-tracker 0 0 12 ' ...
%                '-outfile "' outfile '" ' ...
%                '"' filetotrack '" '];

commandopts = ['-load_state "' ins.configFind '" ' ...
               '-tracker 0 0 12 ' ...
               '-outfile "' outfile '" ' ...
               '"' filetotrack '" '];
           
           
fullcommand = ['"' command '" ' commandopts];
fullcommandj = join(fullcommand);

setenv('PATH', mypath);
setenv('TCL_LIBRARY', tclpath);
setenv('TK_LIBRARY', tkpath);

systemSTR= fullcommandj;
         
systemSTRj = join(systemSTR, '');

disp(systemSTRj);
cd(ins.VSTdir);
system(systemSTRj);
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
