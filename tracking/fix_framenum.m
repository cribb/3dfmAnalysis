function [] = fix_framenum(file)

video_tracking_constants;

original = load_video_tracking(file, [], 'pixels', 1, 'absolute', 'no', 'table');

framenum = original(:,FRAME);
new_framenum = framenum-1;

original(:,FRAME) = new_framenum;

newfile = [file '_fixed'];
save_vrpnmatfile(newfile,original,'pixels');