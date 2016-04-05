function v = tracker_velocity(vstin, fps, smoothness)

if nargin < 3 || isempty(smoothness)
    smoothness = 0.5;
end

if nargin < 2 || isempty(fps)
    error('No frame rate defined.');
end

if nargin < 1 || isempty(vstin)
    error('No data provided on input.');
end

video_tracking_constants;


trackerIDs = unique(vstin(:,ID));
Ntrackers = length(trackerIDs);
Nframes = max(vstin(:,FRAME));
dt = 1/fps;
v = [];

for k = 1:Ntrackers
    myID = trackerIDs(k); 
    
    tracker_ = get_bead(vstin, myID);
    
    x = tracker_(:,X);
    y = tracker_(:,Y);
    
    velx = CreateGaussScaleSpace(x, 1, 0.5)/dt;
    vely = CreateGaussScaleSpace(y, 1, 0.5)/dt;
    
    t_in = [0:length(velx)-1]' * dt + x(1,TIME);
    t_in = t_in(:);
    
    id_in = repmat(myID,length(velx),1);
    
    myvout = horzcat(t_in, id_in, velx, vely);
    myvout(1,:) = [];
    
    v = vertcat(v, myvout);
    
end

return;

% 
%             if get(handles.radio_relative, 'Value')
%                 xinit = x(k); xinit = xinit(1);
%                 yinit = y(k); yinit = yinit(1);        
%             elseif get(handles.radio_arb_origin, 'Value')            
%                 xinit = arb_origin(1);
%                 yinit = arb_origin(2);
% 
%                 % handle the case where 'microns' are selected
%                 if get(handles.radio_microns, 'Value');
%                     xinit = xinit * calib_um;
%                     yinit = yinit * calib_um;                
%                 end                        
%             end
% 
%                       
%             plot(t(k) - mintime, [velx(:) vely(:)], '.-');
%             xlabel('time (s)');
%             ylabel(['velocity [' ylabel_unit '/s]']);
%             legend('x', 'y');    
%             set(handles.AUXfig, 'Units', 'Normalized');
%             set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
%             set(handles.AUXfig, 'DoubleBuffer', 'on');
%             set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;