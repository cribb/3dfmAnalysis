function vc = vst_config_init

arch = computer('arch');
% [~,host] = system('hostname');

vc.VSTdir = 'C:\Program Files (x86)\CISMM\Video_Spot_Tracker_v8.13.0';
vc.VSTcuda = 'video_spot_tracker_local.bat';
vc.VSTexe = 'video_spot_tracker.exe';
% vc.VSTexe = 'video_spot_tracker_nogui.exe';
vc.tclpath = join([vc.VSTdir, filesep, 'tcl8.3'], '');
vc.tkpath = join([vc.VSTdir, filesep, 'tk8.3'], '');
vc.command = join([vc.VSTdir, filesep, vc.VSTexe], '');
vc.os = arch;
% vc.hostname = strip(host);

vst_check_config(vc);

return

