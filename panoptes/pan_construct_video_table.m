% function [filelist, fpslist, calibumlist, width, height, firstframes, mip] = pan_collect_video_data(filepath, systemid, plate_type)
function v = pan_construct_video_table(filepath, systemid, plate_type)

metadata = pan_load_metadata(filepath, systemid, plate_type);


% load the first frames
for k = 1:length(metadata.files.FLburst)
    first_frames{k,1} = imread([metadata.files.FLburst(k).name '\' 'frame0001.pgm']);
    mip_frames{k,1} = imread([metadata.files.mip(k).name]);
    
end

v = first_frames;
