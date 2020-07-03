function [idlist] = extract_indiv_curves (filename, expttype)

%EXTRACT_INDIV_CURVES separates aggregate data and saves new files with
%each individual curve
%
% Extract individual curves from aggregate data set
% yingzhou/desktop/2013.02.08_bladder
% last modified 9/5/13 (yingzhou)
%
% This function takes the aggregate data from cell mechanics experiments
% and divides the data into individual curves stored in different files.
%
%'filename' is the name of the aggregate experimental data set
%'cell_type' is the type of cell data to be split into individual tracks
%
%The output of this function is a matrix of the starting and ending ID numbers of the
%beads tracked. There are no skipped numbers in between. 

video_tracking_constants;

d = load_video_tracking(filename, 30, 'm', 0.152, 'absolute', 'no', 'matrix');
size(unique(d(:,FRAME)),1);

vmsd = video_msd(filename, 40, 30, 0.152, 'n');

idlist = unique(d(:,ID));

for i = 1:length(idlist)  
    idx = find(d(:, ID)==idlist(i));           %finds the indices for the ith curve we want to look at

    single_curve = d(idx,:);                   %puts the ith curve into a new matrix single_curve
    
    %saves the file if the curve does not have NaN elements
    save_evtfile(['single_curve_ID' num2str(idlist(i), '%03u') '_' num2str(expttype) '.vrpn.evt.mat'], single_curve, 'm', 0.152)    

end

return    