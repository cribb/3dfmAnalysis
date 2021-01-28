function JitterTable = yjitter(csvfile, intens_thresh,  min_traj_length, min_pixels, plotTF)

if nargin < 5 || isempty(plotTF)
    plotTF = false;
end

if nargin < 4 || isempty(min_pixels)
    min_pixels = 0;
end

if nargin < 3 || isempty(min_traj_length)
    min_traj_length = 0;
end

% deal with missing intensity threshold. 
if nargin < 2 || isempty(intens_thresh)
    intens_thresh = 0;
end


% Record/define the file directory we start in
rootdir = pwd;

% Pull metadata info for csvfile. 
fname = dir(csvfile);

% Check for the presence of the file
if isempty(fname)
    error('CSV file not found.');
end

% Move to directory that contains data file
cd(fname.folder);

% Provide info about video the trajectories came from
fps = 90;
calibum = 0.1782; % [um/pixel]
width = 1024;
height = 768;
firstframefname = [];
mipfname = [];

% Create the VideoTable that will tell vst_load_tracking how to load and
% scale the trajectories.
VidTable = mk_video_table(fname.name, fps, calibum, ...
                          width, height, firstframefname, mipfname);
                      
% Load the trajectories into TrackingTable
TrackingTable = vst_load_tracking(VidTable);                      

% Convenient output
logentry(['Median Intensity: ', num2str(median(TrackingTable.CenterIntensity)), '.']);

% define the filter parameters for the filtering step
filtin.min_trackers    = 0;
filtin.min_frames      = min_traj_length;
filtin.min_pixels      = min_pixels;
filtin.max_pixels      = Inf;
filtin.max_region_size = Inf;
filtin.min_sens        = 0;
filtin.tcrop           = 0;
filtin.xycrop          = 0;
filtin.xyzunits        = 'pixels';
filtin.calib_um        = 1;
filtin.drift_method    = 'none';
filtin.dead_spots      = [];
filtin.jerk_limit      = [];
filtin.min_intensity   = intens_thresh;
filtin.deadzone        = 0; % deadzone around trackers [pixels]
filtin.overlapthresh   = 0;


% Filter the trajectories. The filtered points go into TrackingTable and
% what gets cut goes into Trash
[TrackingTable, Trash] = vst_filter_tracking(TrackingTable, filtin);

% If everything gets filtered out, throw an error with an explanation
if isempty(TrackingTable)
    error('Intensity threshold is too strict. Choose a lower value.');
end

% Calculate the "jitter" based on the average y-position and Yf-Yo. The
% table is split-up into individual trajectories and passed to a function
% that calculates on eatch group separately
[g, JitterTable.ID] = findgroups(TrackingTable.ID);

ytmp = splitapply(@(y)sa_calc_yjitter(y), TrackingTable.Y * calibum, g);

JitterTable.Ymean = ytmp(:,1);
JitterTable.Ydelta = ytmp(:,2);

JitterTable = struct2table(JitterTable);

if plotTF
    plot_jitter(JitterTable, csvfile(1:end-4));
%     ylim([]);
end

% Return to our starting directory
cd(rootdir);




function outs = sa_calc_yjitter(y)
    meany = mean(y);
    deltay = -( y(end) - y(1) );
    % mean(y(end-5):y(end)) - mean(y(1:5));
    % max(y) - min(y)
    outs = [meany, deltay];
end



function plot_jitter(JitterTable, mytitle)
    maxy = max(abs(JitterTable.Ydelta));
    miny = -maxy;

    % Plot some data, enable data cursor mode, and set the UpdateFcn
    % property to the callback function. Then, create a data tip by 
    % clicking on a data point.
    figure;
    plot(JitterTable.Ydelta, JitterTable.Ymean, 'o');
%     xlabel('y_f - y_o [\mum]');
    xlabel('\Deltay [\mum]');
    ylabel('mean(y) [\mum]');
    title(mytitle, 'Interpreter', 'none');
    xlim([miny maxy]);
    set(gca, 'YDir', 'reverse');

    dcm = datacursormode;
    dcm.Enable = 'on';
    dcm.UpdateFcn = @displayCoordinates;
end
    

function outs = displayCoordinates(~, plotXY)
    
    ydelta = plotXY.Position(1);
    ymean  = plotXY.Position(2);
    
    
    % fid = JitterTable.Fid;    
    row = JitterTable(JitterTable.Ydelta == ydelta & JitterTable.Ymean == ymean,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end


end