function v = summarize_tracking(vst_tracking)

if nargin < 1 || isempty(vst_tracking) || ~isnumeric(vst_tracking)
    logentry('Not tracking input, returning empty tracking summary structure.');
    
    v.framemax = [];
    v.IDs = [];
    v.Ntrackers = [];
    v.tracker_lengths = [];
    v.e2edist = [];
end

video_tracking_constants;


% Total number of frames
v.framemax = max( vst_tracking(:,FRAME) );

% Tracker List of IDs
v.IDs = unique( vst_tracking(:,ID) );

% Total number of trackers
v.Ntrackers = length( v.IDs );

% Tracker Lengths
for k = 1:v.Ntrackers
    this_bead = get_bead(vst_tracking, v.IDs(k));
    
    % Tracker Lengths
    v.tracker_length(k,1) = size(this_bead, 1);
    
    % end-to-end distances    
    v.e2edist(k,1) = sqrt( (this_bead(1,X) - this_bead(end,X)).^2 + ...
                           (this_bead(1,Y) - this_bead(end,Y)).^2 );
    % end-to-end angle
    v.e2eangle(k,1) = atan2( (this_bead(end,Y) - this_bead(1,Y)) , ...
                             (this_bead(end,X) - this_bead(1,X)) );
end



% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'summarize_tracking: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;  