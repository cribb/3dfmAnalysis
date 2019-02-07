function beadstruct = convert_vidtable_to_beadstruct(vidtable)


video_tracking_constants;

if ~isempty(vidtable)
    beadID = vidtable(:,ID);
else
    beadstruct = [];
    return;
end

beadlist = unique(beadID);

for k = 1:length(beadlist)

    idx = find(beadID == k);

    beadstruct(k).t      = vidtable(idx,TIME) - min(vidtable(:,TIME));
    beadstruct(k).x      = vidtable(idx,X);
    beadstruct(k).y      = vidtable(idx,Y);
    beadstruct(k).yaw    = vidtable(idx,YAW);

end
    
    

%     beadID = handles.table(:,ID);
% 
%     for k = 0:max(beadID)
%     
%         idx = find(beadID == k);
% 
%         bead(k+1).t      = handles.table(idx,TIME) - min(handles.table(:,TIME));
%         bead(k+1).x      = handles.table(idx,X);
%         bead(k+1).y      = handles.table(idx,Y);
%         bead(k+1).yaw    = handles.table(idx,YAW);
%         
%     end