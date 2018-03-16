function v = auto_evt(filelist, fps, calibum, filt)


files = dir(filelist);

for k = 1 : length(files)
    
    fname = files(k).name;
    
    [d, ~] = load_video_tracking(fname, fps, 'pixels', calibum, 'absolute', 'no', 'table');
    
    [d, filtout] = filter_video_tracking(d, filt);
    
    filtout.name = fname;
    filtout.fps  = fps;
    
    v(k) = filtout;
    
    save_evtfile(fname, d, 'pixels', calibum, fps, 'mat');
    
end

