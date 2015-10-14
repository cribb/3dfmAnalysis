function [] = fix_framenum(files)
%input files must be cells with file paths (ie. files{1} =
%Users/phoebelee/...)

video_tracking_constants;

for f = 1:length(files)
    file = files{f};
    
    data = load_video_tracking(file,[],'pixels',1,'absolute','no','table');
    framenum = data(:,FRAME);
    new_frame = framenum - 1;
    
    data(:,FRAME) = new_frame;
    
    new_file = [file '_fixed'];
    save_vrpnmatfile(new_file,data,'pixels');
    
    %data_set.(file) = data;
end
