function JitterTable = trajitter(csvfile, intens_thresh,  min_frames, min_pixels, plotXY, binnum)

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


% Provide info about video the trajectories came from
fps = 29;
calibum = 0.1782; % [um/pixel]
width = 1024;
height = 768;
% Ybinnum = 16;
firstframefname = [];
mipfname = [];

% Create the VideoTable that will tell vst_load_tracking how to load and
% scale the trajectories.
VidTable = mk_video_table(csvfile, fps, calibum, ...
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
% TrackingTable0 = TrackingTable;
[TrackingTable, Trash] = vst_filter_tracking(TrackingTable, filtin);

% If everything gets filtered out, throw an error with an explanation
if isempty(TrackingTable)
    error('Intensity threshold is too strict. Choose a lower value.');
end


% Calculate fits for the X and Y trajectories for each path 
[g, ~] = findgroups(TrackingTable(:,{'Fid', 'ID'}));

xytmp = splitapply(@(q1, q2, q3, q4){sa_calc_xyfits(q1, q2, q3, q4)}, TrackingTable.Fid, ...
                                                                      TrackingTable.ID, ...
                                                                      TrackingTable.Frame, ...
                                                                      [TrackingTable.X, TrackingTable.Y], ...
                                                                      g );
xytmp = cell2mat(xytmp);

FitTable.Fid = xytmp(:,1);
FitTable.ID = xytmp(:,2);
FitTable.Frame = xytmp(:,3);
FitTable.Xmodel = xytmp(:,4);
FitTable.Ymodel = xytmp(:,5);
FitTable.Xresiduals = xytmp(:,6);
FitTable.Yresiduals = xytmp(:,7);

FitTable = struct2table(FitTable);

TrackingTable = innerjoin(TrackingTable, FitTable);


% Calculate the "jitter" based on the average y-position and Yf-Yo. The
% table is split-up into individual trajectories and passed to a function
% that calculates on each group separately
[gj, JitterTable] = findgroups(TrackingTable(:,{'Fid', 'ID'}));

xytmp = splitapply(@(q1,q2)sa_calc_xyjitter(q1, q2), [TrackingTable.X,      TrackingTable.Y     ], ...
                                                     [TrackingTable.Xmodel, TrackingTable.Ymodel], gj);
JitterTable.Xi = xytmp(:,1);
JitterTable.Xmean = xytmp(:,2);
JitterTable.Xdelta = xytmp(:,3);
JitterTable.Yi = xytmp(:,4);
JitterTable.Ymean = xytmp(:,5);
JitterTable.Ydelta = xytmp(:,6);
JitterTable.RMSE = xytmp(:,7);
if isstruct(JitterTable)
    JitterTable = struct2table(JitterTable);
end

%define bins and average ydelta for each bin

% % % %using initial y position of individual track to define which bin a tracker
% % % %ends up in
% % % [n, edge, bins] = histcounts(JitterTable.Yi, binnum);

% Using mean y position of individual track to define which bin a tracker
% ends up in

[n, edges, bins] = histcounts(JitterTable.Ymean, binnum);

[binsg, BG] = findgroups(bins);
Nb = splitapply(@numel, binsg, binsg);


%    Calculate the new tables here JAKE CODE


if contains(plotXY, 'X') || contains(plotXY, 'Y')
    plot_boxes;
    plot_jitter(JitterTable, csvfile(1:end-4), plotXY);
    
    overlayfig = figure;   
    plot_jitter(JitterTable, csvfile(1:end-4), plotXY, overlayfig);
    plot_boxes(overlayfig);
    %     plot_jakermse(JitterTable, csvfile(1:end-4), plotXY);
end


% Return to our starting directory
cd(rootdir);


% Ancillary functions within the context of main/title function 
function bin_out = um2bin(um)
    bin_out = (um/calibum).*(binnum/height);    
end

function um_out = bin2um(bin)
    um_out = bin * height/binnum * calibum;
end
    
function bin_out = pix2bin(pix)
    bin_out = pix * (binnum/height);
end

function pix_out = bin2pix(bin)
    pix_out = bin * (height/binnum);
end

function um_out = pix2um(pix)
    um_out = pix * calibum;
end

function pix_out = um2pix(um)
    pix_out = um / calibum;
end


function outs = sa_calc_xyfits(fid, id, frame, xy)
    TrajFitFraction = 0.1;
    order = 1;
        
    N = ceil(numel(frame)*TrajFitFraction);
        
    xfit = polyfit(frame(1:N), xy(1:N,1), order);
    yfit = polyfit(frame(1:N), xy(1:N,2), order);
    
    xmodel = polyval(xfit, frame);
    ymodel = polyval(yfit, frame);
    
    % Calculate residuals
    xres = xy(:,1) - xmodel;
    yres = xy(:,2) - ymodel;
    
    % (:) means linearize the matrix (creates column vectors)
    
    outs = [fid(:), id(:), frame(:), xmodel(:), ymodel(:), xres(:), yres(:)];
end


function outs = sa_calc_xyjitter(xy, xymodel)
    meanxy = mean(xy,1);
    
    deltax =  ( xy(end,1) - xymodel(end,1) );
    deltay = -( xy(end,2) - xymodel(end,2) );
    % mean(xy(end-5:end,:) - mean(xy(1:5,:));
    % max(y) - min(y)
    
    xi = xy(1,1);
    yi = xy(1,2);
    
    rmse = sqrt(mean((xy-xymodel).^2));
    
    if isempty(rmse)
        outs = zeros(1,5);
    end

    outs = [xi, meanxy(:,1), deltax, yi, meanxy(:,2), deltay, rmse];
end


function plot_boxes(fig)
    if nargin < 1 || isempty(fig)
        fig = figure;
    end
    
    figure(fig);
    hold on;
    boxplot(pix2um(JitterTable.Ydelta), binsg, 'Notch', 'off', ...
                                       'Whisker', 2, ...
                                        'Plotstyle', 'compact', ...
                                       'Labels', BG, ...
                                       'Orientation', 'horizontal', ...
                                       'Positions', (1:binnum)-0.5);

    ymin = 0;
    ymax = binnum;
    ylim([ymin, ymax]);
    ytick_um(:,1) = [0:10:130];
    ytick_grp = um2bin(ytick_um);
    ax = gca;
    ax.YDir = 'reverse';
    ax.YTick = ytick_grp;
    ax.YTickLabel = num2str(ytick_um);
    ylabel('Mean (y) [\mum]');
    xlabel('\Deltay [\mum]');

    title('\Deltay');
    hold off;
    grid on;
end

function plot_jitter(JitterTable, mytitle, plotXY, fig)
% Plot some data, enable data cursor mode, and set the UpdateFcn
% property to the callback function. Then, create a data tip by 
% clicking on a data point.
    if nargin < 4 || isempty(fig)
        fig = figure;
    end

    figure(fig);
    hold on;
    switch plotXY
        case 'X'
            maxx = max(abs(pix2bin(JitterTable.Xdelta)));
            minx = -maxx;

            plot(pix2bin(JitterTable.Xmean), pix2um(JitterTable.Xdelta), 'o', 'Color', [0.6 0.6 0.6]);
            xlabel('mean(x) [\mum]');
            ylabel('\Deltax [\mum]');
%             ylim([minx maxx]);
            dcm = datacursormode;
            dcm.Enable = 'on';            
            dcm.UpdateFcn = @displayCoordinatesX;
        case 'Y'
            maxy = max(abs(pix2bin(JitterTable.Ydelta)));
            miny = -maxy;

            plot(pix2um(JitterTable.Ydelta), pix2bin(JitterTable.Ymean), 'o', 'Color', [0.6 0.6 0.6]);
            xlabel('\Deltay [\mum]');
            ylabel('mean(y) [\mum]');
%             xlim([miny maxy]);
            set(gca, 'YDir', 'reverse');
            dcm = datacursormode;
            dcm.Enable = 'on';            
            dcm.UpdateFcn = @displayCoordinatesY;
    end
    title(mytitle, 'Interpreter', 'none');
    grid on;
end


function outs = displayCoordinatesX(~, plotXY)
    
    xmean_bin  = plotXY.Position(1);
    xdelta_bin = plotXY.Position(2);
    
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.Xdelta - bin2pix(xdelta_bin)) < 0.001 & ...
                      abs(JitterTable.Xmean  - bin2pix(xmean_bin)) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end


function outs = displayCoordinatesY(~, plotXY)
    
    ydelta_bin = plotXY.Position(1);
    ymean_bin  = plotXY.Position(2);
       
    % fid = JitterTable.Fid;    
    row = JitterTable(abs(JitterTable.Ydelta - um2pix(ydelta_bin)) < 0.001 & ...
                      abs(JitterTable.Ymean  - bin2pix(ymean_bin)) < 0.001,:);        
    
    % may need to add FID later in case more than one file is loaded
    % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
    outs = ['ID = ' num2str(row.ID)];    
end


% % % 
% % % function outs = displayRmseX(~, plotXY)
% % %     
% % %     xmean_um  = plotXY.Position(1);
% % %     rmse_um = plotXY.Position(2);
% % %     
% % %     % fid = JitterTable.Fid;    
% % %     row = JitterTable(abs(JitterTable.RMSE - um2pix(rmse_um)) < 0.001 & ...
% % %                       abs(JitterTable.Xmean - um2pix(xmean_um)) < 0.001,:);        
% % %     
% % %     % may need to add FID later in case more than one file is loaded
% % %     % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
% % %     outs = ['ID = ' num2str(row.ID)];    
% % % end
% % % 
% % % 
% % % function outs = displayRmseY(~, plotXY)
% % %     
% % %     rmse_um = plotXY.Position(1);
% % %     ymean_um  = plotXY.Position(2);
% % %        
% % %     % fid = JitterTable.Fid;    
% % %     row = JitterTable(abs(JitterTable.RMSE - um2pix(rmse_um)) < 0.001 & ...
% % %                       abs(JitterTable.Ymean - um2pix(ymean_um)) < 0.001,:);        
% % %     
% % %     % may need to add FID later in case more than one file is loaded
% % %     % outs = ['Fid = ', num2str(row.Fid), ', ID = ' num2str(row.ID)];       
% % %     outs = ['ID = ' num2str(row.ID)];    
% % % end
% % % 
% % % 
% % % function plot_rmse(JitterTable, mytitle, plotXY)
% % %     
% % %         maxx = max(abs(JitterTable.Xdelta*calibum));
% % %         minx = -maxx;
% % % 
% % %     figure;
% % %     switch plotXY 
% % %         case 'X'           
% % %             plot(pix2um(JitterTable.Xmean), pix2um(JitterTable.RMSE), 'o');
% % %             xlabel('mean(x) [\mum]');
% % %             ylabel('RMSE(x) [\mum]');
% % % %             ylim([minx maxx]);
% % %             dcm = datacursormode;
% % %             dcm.Enable = 'on';
% % %             dcm.UpdateFcn = @displayRmseX;
% % %         case 'Y'
% % %             plot(pix2um(JitterTable.RMSE), pix2um(JitterTable.Ymean), 'o');
% % %             xlabel('RMSE(y) [\mum]');
% % %             ylabel('mean(y) [\mum]');
% % % %             xlim([miny maxy]);
% % %             set(gca, 'YDir', 'reverse');
% % %             dcm = datacursormode;
% % %             dcm.Enable = 'on';            
% % %             dcm.UpdateFcn = @displayRmseY;
% % %     end
% % %     title(mytitle, 'Interpreter', 'none');    
% % % end


end