function ax = pan_plot_tracker_overlay(DataIn, fid, id, h, opts)

if nargin < 4 || isempty(h)
    h = figure;
end

if nargin < 5 || isempty(opts)
    opts = 'mose'; % (f)irstframe, (m)ip, (o)riginal trajectory, filtered (t)rajectory, (s)tart glyph, (e)nd glyph, (v)ector arrow.
end

if nargin < 1 || isempty(DataIn)
    error('No data found. Need output from pan_new_analysis to run properly.');
end

if nargin < 2 && isempty(fid)
    error('Need at least an Fid to select images and trajectories by.');
elseif isempty(fid) && ~isempty(id)
    error('ID selected with no Fid defined.');
elseif nargin < 3 || isempty(id) % Select all trajectories in Fid.
    FidOnly = true;
    imIDX   = ( DataIn.ImageTable.Fid == fid ); 
    trajIDX = ( DataIn.TrackingTable.Fid == fid );
elseif ~isempty(fid) && ~isempty(id) % Select just one ID traj in Fid.
    FidOnly = false;    
    imIDX   = ( DataIn.TrajImageTable.Fid == fid & DataIn.TrajImageTable.ID == id );
    trajIDX = ( DataIn.TrackingTable.Fid == fid & DataIn.TrackingTable.ID == id );
else

end

if FidOnly
    im = DataIn.ImageTable(imIDX,:);
else
    im = DataIn.TrajImageTable(imIDX,:);    
end
traj = DataIn.TrackingTable(trajIDX,:);

% Pull out the proper image
if FidOnly
    if contains(opts, 'f')
        myim = im.FirstFrames{1};
    elseif contains(opts, 'm')
        myim = im.Mips{1};
    elseif ~contains(opts, 'f') && ~contains(opts, 'm')
        myim = im.Mips{1};
    end
else % Fids and IDs are present
    if contains(opts, 'f')
        myim = im.beadImageFF{1};
    elseif contains(opts, 'm')
        myim = im.beadImageMIP{1};
    elseif ~contains(opts, 'f') && ~contains(opts, 'm')
        myim = im.beadImageMIP{1};
    end
end


% Pull out the proper point/trajectory
% (o)riginal trajectory, filtered (t)rajectory,
myXo = mean(traj.Xo);
myYo = mean(traj.Yo);
Xoffset = size(myim,2)/2;
Yoffset = size(myim,1)/2;

otrajx = []; otrajy = [];
ttrajx = []; ttrajy = [];

if FidOnly
    if contains(opts, 'o')
        otrajx = traj.Xo;
        otrajy = traj.Yo;
    end
    
    if contains(opts, 't')
        ttrajx = traj.X;
        ttrajy = traj.Y;
    end
else
    if contains(opts, 'o')
        otrajx = traj.Xo - myXo + Xoffset;
        otrajy = traj.Yo - myYo + Yoffset;
    end
    
    if contains(opts, 't')
        ttrajx = traj.X - myXo + Xoffset;
        ttrajy = traj.Y - myYo + Yoffset;
    end
end    

figure(h);
imagesc(myim);
colormap(gray(256));
axis off;

figure(h);
hold on;
plot(otrajx, otrajy, '.r', ttrajx, ttrajy, '.g');

ax = 0;

return
