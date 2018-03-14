function v = auto_evt(filelist, fps, calibum, filt)


files = dir(filelist);

for k = 1 : length(files)
    
    fname = files(k).name;
    
    [d, ~] = load_video_tracking(fname, fps, 'pixels', calibum, 'absolute', 'no', 'table');
    
    d = filter_video_tracking(d, filt);
    
    save_evtfile(fname, d, 'pixels', calibum, fps, 'mat');
    
end

v = 0;
