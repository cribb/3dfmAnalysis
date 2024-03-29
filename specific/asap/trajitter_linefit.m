function JitterTable = trajitter_linefit(csvfile, intens_thresh,  min_frames, min_pixels, plotXY)

if nargin < 5 || isempty(plotXY)
    plotXY = '';
end

if nargin < 4 || isempty(min_pixels)
    min_pixels = 0;
end

if nargin < 3 || isempty(min_frames)
    min_frames = 0;
end

% deal with missing intensity threshold. 
if nargin < 2 || isempty(intens_thresh)
    intens_thresh = 0;
end


% Record/define the file directory we start in
rootdir = pwd;

plotXY = upper(plotXY);
switch plotXY
    case 'X'
    case 'Y'
    otherwise
        error('plotXY must be either ''X'' or ''Y''.');
end

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
filtin.min_frames      = min_frames;
filtin.min_pixels      = min_pixels;
filtin.max_pixels      = Inf;
filtin.max_region_size = Inf;
filtin.min_sens        = 0;
filtin.tcrop           = 0;
filtin.xycrop          = 0;
filtin.width           = width;
filtin.height          = height;
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
[g, FitTable.ID] = findgroups(TrackingTable.ID);

xy = [TrackingTable.X, TrackingTable.Y] * calibum;

xytmp = splitapply(@(id, frame, xy){sa_calc_xyfits(id, frame, xy)}, TrackingTable.ID, TrackingTable.Frame, [TrackingTable.X, TrackingTable.Y], g);
xytmp = cell2mat(xytmp);

FitTable.ID = xytmp(:,1);
FitTable.Frame = xytmp(:,2);
FitTable.Xmodel = xytmp(:,3);
FitTable.Ymodel = xytmp(:,4);
FitTable.Xresiduals = xytmp(:,5);
FitTable.Yresiduals = xytmp(:,6);

FitTable = struct2table(FitTable);

TrackingTable = innerjoin(TrackingTable, FitTable);

[gj, JitterTable.ID] = findgroups(TrackingTable.ID);

xytmp = splitapply(@(xy1,xy2)sa_calc_xyjitter(xy1, xy2), [TrackingTable.X,      TrackingTable.Y     ], ...
                                                         [TrackingTable.Xmodel, TrackingTable.Ymodel], gj);

JitterTable.Xmean = xytmp(:,1);
JitterTable.Xdelta = xytmp(:,2);
JitterTable.Ymean = xytmp(:,3);
JitterTable.Ydelta = xytmp(:,4);
JitterTable.RMSE = xytmp(:,5);
JitterTable = struct2table(JitterTable);





if contains(plotXY, 'X') || contains(plotXY, 'Y')
    plot_jitter(JitterTable, csvfile(1:end-4), plotXY);
    plot_rmse(JitterTable, csvfile(1:end-4), plotXY);
%     ylim([]);
end


% Return to our starting directory
cd(rootdir);


function outs = sa_calc_xyfits(id, frame, xy)
    TrajFitFraction = 1;
    order = 2;
        
    N = ceil(numel(frame)*TrajFitFraction);
        
    xfit = polyfit(frame(1:N), xy(1:N,1), order);
    yfit = polyfit(frame(1:N), xy(1:N,2), order);
    
    xmodel = polyval(xfit, frame);
    ymodel = polyval(yfit, frame);
    
    % Calculate residuals
    xres = xy(:,1) - xmodel;
    yres = xy(:,2) - ymodel;
    
    outs = [id(:), frame(:), xmodel(:), ymodel(:), xres(:), yres(:)];
end


function outs = sa_calc_xyjitter(xy, xymodel)
    meanxy = mean(xy,1);
    
    deltax =  ( xy(end,1) - xymodel(end,1) );
    deltay = -( xy(end,2) - xymodel(end,2) );
    % mean(xy(end-5:end,:) - mean(xy(1:5,:));
    % max(y) - min(y)
    
    rmse = sqrt(mean((xy-xymodel).^2));

    outs = [meanxy(:,1), deltax, meanxy(:,2), deltay, rmse];
end

function plot_rmse(JitterTable, mytitle, plotXY)
    
        maxx = max(abs(JitterTable.Xdelta*calibum));
        minx = -maxx;

    figure;
    switch plotXY 
        case 'X'           
            plot(JitterTable.Xmean * calibum, JitterTable.RMSE * calibum, 'o');
            xlabel('mean(x) [\mum]');
            ylabel('RMSE(x) [\mum]');
%             ylim([minx maxx]);
            dcm = datacursormode;
            dcm.Enable = 'on';
            dcm.UpdateFcn = @displayRmseX;
        case 'Y'
            plot(JitterTable.RMSE * calibum, JitterTable.Ymean * calibum, 'o');
            xlabel('RMSE(y) [\mum]');
            ylabel('mean(y) [\mum]');
%             xlim([miny maxy]);
            set(gca, 'YDir', 'reverse');
            dcm = datacursormode;
            dcm.Enable = 'on';            
            dcm.UpdateFcn = @displayRmseY;
    end
    title(mytitle, 'Interpreter', 'none');

    
end

function plot_jitter(JitterTable, mytitle, plotXY)

% Plot some data, enable data cursor mode, and set the UpdateFcn
% property to the callback function. Then, create a data tip by 
% clicking on a data point.

    figure;
    switch plotXY
        case 'X'
            maxx = max(abs(JitterTable.Xdelta*calibum));
            minx = -maxx;

            plot(JitterTable.Xmean * calibum, JitterTable.Xdelta * calibum, 'o');
            xlabel('mean(x) [\mum]');
            ylabel('\Deltax [\mum]');
            ylim([minx maxx]);
            dcm = datacursormode;
            dcm.Enable = 'on';            
            dcm.UpdateFcn = @displayCoordinatesX;
        case 'Y'
            maxy = max(abs(JitterTable.Ydelta)*calibum);
            miny = -maxy;

            plot(JitterTable.Ydelta * calibum, JitterTable.Ymean * calibum, 'o');
            xlabel('\Deltay [\mum]');
            ylabel('mean(y) [\mum]');
            xlim([miny maxy]);
            set(gca, 'YDir', 'reverse');
            dcm = datacursormode;
            dcm.Enable = 'on';            
            dcm.UpdateFcn = @displayCoordinatesY;
    end
    title(mytitle, 'Interpreter', 'none');
    
end
    
function attachDataTips(XorY)
    dcm = datacursormode;
    dcm.Enable = 'on';
    switch upper(XorY)
        case 'X'
            dcm.UpdateFcn = @displayCoordinatesX;
        case 'Y'
            dcm.UpdateFcn = @displayCoordinatesY;
    end           
end


function outs = displayCoordinatesX(~, plotXY)
    
    xmean_um  = plotXY.Position(1);
    xdelta_um = plotXY.Position(2);
    
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.Xdelta - xdelta_um/calibum) < 0.001 & ...
                      abs(JitterTable.Xmean  - xmean_um/calibum) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end


function outs = displayCoordinatesY(~, plotXY)
    
    ydelta_um = plotXY.Position(1);
    ymean_um  = plotXY.Position(2);
       
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.Ydelta - ydelta_um/calibum) < 0.001 & ...
                      abs(JitterTable.Ymean  - ymean_um/calibum) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end

function outs = displayRmseX(~, plotXY)
    
    xmean_um  = plotXY.Position(1);
    rmse_um = plotXY.Position(2);
    
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.RMSE - rmse_um/calibum) < 0.001 & ...
                      abs(JitterTable.Xmean - xmean_um/calibum) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end


function outs = displayRmseY(~, plotXY)
    
    rmse_um = plotXY.Position(1);
    ymean_um  = plotXY.Position(2);
       
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.RMSE - rmse_um/calibum) < 0.001 & ...
                      abs(JitterTable.Ymean - ymean_um/calibum) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end

end