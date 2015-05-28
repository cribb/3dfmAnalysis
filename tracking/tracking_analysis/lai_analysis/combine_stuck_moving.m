function combine_stuck_moving(filename)
% filename is the base movie name; it does not contain ' (Moving)' or 
% ' (Stuck)' at the end, nor does it contain the file extension

% MODIFY THESE PARAMETERS AS NEEDED
conversion = 0.156; % Lai Lab Axiovert
frame_rate = 15; % frames/sec
min_frames = 50;
duplicate_cutoff = 300;
sheetname = 'Sheet3';
file_extension = '.xlsx'; % This is the typical output format for MPT_combined_v2, but change to '.xls' if needed

stuck_filename = [filename ' (Stuck)' file_extension];
XY_stuck = xlsread(stuck_filename,'XY Stuck');

moving_filename = [filename ' (Moving)' file_extension];
XY_moving = xlsread(moving_filename,'XY Moving');

final_output_filename = [filename '_Final' file_extension];
XY_all = [XY_stuck; XY_moving];
xlswrite(final_output_filename,XY_all,sheetname);

MPT_combined_v2(final_output_filename,sheetname,conversion,frame_rate,min_frames,duplicate_cutoff)