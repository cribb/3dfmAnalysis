function out_struct_array = convert_vidtable_to_beadstruct(vidtable)


video_tracking_constants;

beadID = unique(vidtable(:,ID));

for k = 0:max(beadID)

    idx = find(beadID == k);

    bead(k+1).t      = vidtable(idx,TIME) - min(vidtable(:,TIME));
    bead(k+1).x      = vidtable(idx,X);
    bead(k+1).y      = vidtable(idx,Y);
    bead(k+1).yaw    = vidtable(idx,YAW);

end

bead = out_struct_array;
    
    