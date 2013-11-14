function beadstruct = convert_vidtable_to_beadstruct(vidtable)


video_tracking_constants;

if ~isempty(vidtable)
    beadID = vidtable(:,ID);
else
    beadstruct = [];
    return;
end

for k = 0:max(beadID)

    idx = find(beadID == k);

    beadstruct(k+1).t      = vidtable(idx,TIME) - min(vidtable(:,TIME));
    beadstruct(k+1).x      = vidtable(idx,X);
    beadstruct(k+1).y      = vidtable(idx,Y);
    beadstruct(k+1).yaw    = vidtable(idx,YAW);

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