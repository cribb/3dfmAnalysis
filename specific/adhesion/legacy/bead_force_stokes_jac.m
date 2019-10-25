function d = bead_force_stokes_jac(filelist, fps, calibum, zstep, bead_diameter_um, std_viscosity_Pas, width, height, lolim, hilim)
% how this works

if nargin < 10 || isempty(hilim)
    hilim = 250;
end

if nargin < 9 || isempty(lolim)
    lolim = 52;
end

if nargin < 8 || isempty(height)
    height = NaN;
end

if nargin < 7 || isempty(width)
    width = NaN;
end

if nargin < 6 || isempty(std_viscosity_Pas)
    std_viscosity_Pas = 0;
end

if nargin < 5 || isempty(bead_diameter_um)
    bead_diameter_um = 24;   
    
end

if nargin < 4 || isempty(zstep)
    error('No Zstep calibration defined.');
end

if nargin < 3 || isempty(calibum)
    error('No calibration factor defined.');
end

if nargin < 2 || isempty(fps)
	error('FPS not defined.');
end

clear calcZvel_jac;

filelist = dir(filelist);
filelist = {filelist.name};

N = length(filelist);

fpslist = repmat(fps, N, 1);
calibumlist = repmat(calibum, N, 1);

Zstep = repmat(zstep, N, 1);
BeadDiameter = repmat(bead_diameter_um, N, 1);
StdViscosity = repmat(std_viscosity_Pas, N, 1);
VidWidth = repmat(width, N, 1);
VidHeight = repmat(height, N, 1);

d.VidTable = mk_video_table(filelist, fpslist, calibumlist, width, height, [], []);

% AUGMENT standard table
Augs = table(Zstep, BeadDiameter, StdViscosity, VidWidth, VidHeight);
d.VidTable = [d.VidTable Augs];
d.VidTable.Properties.VariableUnits{'Zstep'} = 'um';
d.VidTable.Properties.VariableUnits{'BeadDiameter'} = 'um';
d.VidTable.Properties.VariableUnits{'StdViscosity'} = 'Pa s';

d.TrackingTable = vst_load_tracking(d.VidTable);

jTable = join(d.TrackingTable(:,{'Fid', 'Frame', 'ID', 'X', 'Y', 'Z', 'Radius', 'CenterIntensity', 'Sensitivity'}), ...
              d.VidTable(:,{'Fid', 'Fps', 'Calibum'}));

jTable.X = jTable.X .* jTable.Calibum; % [xPixels] -> [um]
jTable.Properties.VariableUnits{'X'} = 'um';

jTable.Y = jTable.Y .* jTable.Calibum; % [yPixels] -> [um]
jTable.Properties.VariableUnits{'Y'} = 'um';

jTable.Z = jTable.Z .* jTable.Calibum; % [stepsize] -> [um]
jTable.Properties.VariableUnits{'Z'} = 'um';

jTable.Time = jTable.Frame ./ jTable.Fps; % [frame #] -> [sec] 
jTable.Properties.VariableUnits{'Time'} = 's';

[g, grpTable] = findgroups(jTable(:,{'Fid', 'ID'}));

tmpVels = splitapply(@(x1,x2,x3,x4,x5) calcZvel_xyz(x1, x2, x3, x4, x5, lolim, hilim), ...
                    jTable.Time, ...
                    jTable.ID, ...
                    jTable.X, ...
                    jTable.Y, ...
                    jTable.Z, ...
                    g);

T.FirstTime = tmpVels(:,1);
T.Zvel      = tmpVels(:,2);
T.ZfitRmse  = tmpVels(:,3);
T.ZposMean  = tmpVels(:,4);
T.ZposRange = tmpVels(:,5);
T.CVerr     = tmpVels(:,6);
T.Nframes   = tmpVels(:,7);

T = struct2table(T);

T.Properties.VariableUnits{'FirstTime'} = 's';
T.Properties.VariableUnits{'Zvel'} = 'um/s';
T.Properties.VariableUnits{'ZfitRmse'} = 'um';
T.Properties.VariableUnits{'ZposMean'} = 'um';
T.Properties.VariableUnits{'ZposRange'} = 'um';

T = [grpTable, T];

T = join(T, d.VidTable(:,{'Fid', 'BeadDiameter', 'StdViscosity'}));

T.Zforce = 6 * pi .* T.BeadDiameter .* 1e-6 ./ 2 ... % um -> m, diameter -> radius
                  .* T.StdViscosity ...              % Pa s
                  .* T.Zvel         .* 1e-6;         % um/s -> m/s

T.Properties.VariableUnits{'Zforce'} = 'N';

T(:,{'BeadDiameter', 'StdViscosity'}) = [];

d.ZforceTable = T;

figure; 
gscatter(jTable.Time, jTable.Z, g);
xlabel('Time [s]');
ylabel('Z pos [um]');


figure;
gscatter(jTable.Time, CreateGaussScaleSpace(jTable.Z, 1, 8).*jTable.Fps, g);
xlabel('Time [s]');
ylabel('Z velocity [um/s], s=8');

return

function outs = calcZvel_jac(frames, trackerid, xpos, ypos, zpos, lowlim, highlim)

%     first = find(zpos >  lowlim, 1);
%     last  = find(zpos > highlim, 1);
%     
%     if isempty(last)
%         frames = frames(first:end);
%         zpos = zpos(first:end);
%     else
%         frames = frames(first:last-1);
%         zpos = zpos(first:last-1);
%     end
    
    [~,low] = min(zpos);
    if low ~= 1
        zpos(1:low) = [];
        frames(1:low) = [];
    end
    
    [~,high] = max(zpos);
    if high ~= length(zpos)
        zpos(high+1:end) = [];
        frames(high+1:end) = [];
    end

    
    persistent gcount    
    
    if isempty(gcount)
        gcount = 1;
    else
        gcount = gcount + 1;
    end
    
    fprintf('gcount=%d\n', gcount);

        
    [uZ, Ff] = unique(round(zpos), 'first');
    midrangeuZ = mean(range(uZ));
%     targetuZ = median(uZ) - 0.5*std(uZ);
    targetuZ = midrangeuZ;

    [~,pos_targetuZ] = min(abs(zpos-targetuZ));

    CVlim = 0.2;
    CVerr = 0; 
    Pstep = 2; 
    Nstep = 2;
    count = 1;
    
    [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, myframes, fitZ] = deal(NaN);    
    
    while CVerr < CVlim && ...
          pos_targetuZ + Pstep < length(zpos) && ...
          pos_targetuZ - Nstep >= 1


        myframes = frames(pos_targetuZ - Nstep : pos_targetuZ + Pstep);
        myzpos   =   zpos(pos_targetuZ - Nstep : pos_targetuZ + Pstep);

        fit  = polyfit(myframes(:), myzpos(:), 1);
        fitZ = polyval(fit, myframes(:));

        firstframe = myframes(1);
        Zvel = fit(1); % [stepsize/frame]    
        ZfitRmse = sqrt(sum((myzpos-fitZ).^2));
        ZposMean = mean(myzpos);
        ZposRange = range(myzpos);

        CVerr = ZfitRmse / ZposMean;

        fprintf('count= %i, CVerr= %0.2g\n', count, CVerr);

        if mod(count,2)
            Pstep = Pstep + 1;
        else
            Nstep = Nstep + 1;
        end

        count = count + 1;
        
    end

    outs = [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, CVerr];
    
    
    figure;
    plot(frames, zpos, '.b', ...
         frames(Ff), uZ, 'ok', ...
         myframes, fitZ, '-r', ...
         frames(pos_targetuZ), targetuZ, 'xc');
    legend('All Z-pos', 'Unique Z', 'Fitted Z', 'Mid-Range uZ');
    
    % outs = {x, y, coef};
    
return


function outs = calcZvel(frames, trackerid, xpos, ypos, zpos, lowlim, highlim)

%     first = find(zpos >  lowlim, 1);
%     last  = find(zpos > highlim, 1);
    
    first = 1;
    last = length(zpos);
    
    myID = unique(trackerid);
    
    if isempty(last)
        frames = frames(first:end);
        zpos = zpos(first:end);
    else
        frames = frames(first:last(1)-1);
        zpos = zpos(first:last(1)-1);
    end
    
    [~, midx] = max(zpos);
    [minz, ~] = min(zpos);
    
    if midx ~= length(zpos)
        zpos = zpos(1:midx);
        frames = frames(1:midx);
    end
    
    midrange = ceil(range(zpos)/2 + minz);   % Middle of the range
    [midz, mid_zidx] = min(abs(zpos - midrange));
    lowerflat = mode(zpos(1:mid_zidx));
    
    
    [~, idxF] = unique(zpos, 'first');
    [~, idxL] = unique(zpos, 'last');
    
    idx = union(idxF,idxL);
    idxD = (diff(idx) <= 2);
    idxD = logical([0;idxD]);
    idxU = idx( idxD );
    
    zpos_for_fitting = zpos(idxU);
    frames_for_fitting = frames(idxU);
    Nframes = length(idxU);
    
    order = 1;

    if length(frames_for_fitting) < order + 2
        outs = NaN(1,7);
        return;
    end        
    
    CVerr = inf;
    
   while CVerr > 0.5 && length(frames_for_fitting) >= order + 2 % magic number, 50% RMSE CVerr

       if isfinite(CVerr)
          frames_for_fitting = frames_for_fitting(2:end);
          zpos_for_fitting = zpos_for_fitting(2:end);
          Nframes = Nframes - 1;
       end
       
        fit = polyfit(frames_for_fitting, zpos_for_fitting, order);
        fitZ = polyval(fit, frames_for_fitting);

        firstframe = frames(1);
        Zvel = fit(1); % [stepsize/frame]
    %     Zvel = 2*fit(1)*frames(end) + fit(2);
        ZfitRmse = sqrt(sum((zpos_for_fitting-fitZ).^2));
        ZposMean = mean(zpos_for_fitting);
        ZposRange = range(zpos_for_fitting);
        CVerr = ZfitRmse / ZposMean;
    end
    outs = [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, CVerr, Nframes];
    
    figure;
    hold on;
    plot(frames,             zpos,             'Marker', 'o', 'MarkerEdgeColor', [0.75 0.75 0.75], 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    plot(frames(idx),        zpos(idx),        'Marker', 'x', 'MarkerSize', 14, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    plot(frames_for_fitting, zpos_for_fitting, 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineStyle', 'none');
    plot(frames_for_fitting, fitZ, 'Marker', 'x', 'MarkerEdgeColor', 'r', 'LineStyle', '-', 'Color', 'r');
    hold off;
    xlabel('Time [s]');
    ylabel('Zpos [um]');
    legend('zpos', 'first&lastUniq', 'UsedInFit', 'fit', 'Location','northwest');
    title(['trackerID = ' num2str(myID)]);
    xlim([min(frames_for_fitting)-4*mean(diff(frames)) max(frames_for_fitting)+mean(diff(frames))]);
return


function outs = calcZvel_easy(frames, trackerid, xpos, ypos, zpos, lowlim, highlim)

    myID = unique(trackerid);
    
    % Where is the minimum value
    [~, minidx] = min(zpos);
    
    zpos = zpos(minidx:end);
    frames = frames(minidx:end);
    
    
    % Choose how long the dataset needs to be before we consider it. If
    % it's too short, return NaN for this tracker.
    if length(zpos) < 10
        outs = NaN(1,7);
        disp('Not enough points to run algorithm.');
    end
    

%     if isempty(last)
%         frames = frames(first:end);
%         zpos = zpos(first:end);
%     else
%         frames = frames(first:last(1)-1);
%         zpos = zpos(first:last(1)-1);
%     end

    % Next, where is the maximum z for this tracker located? If a tracker
    % is moving down, it's not one we want to measure velocity for.
    % Consider drawing out this part of the process into a different
    % function.    
    [maxz, maxidx] = max(zpos);
    [minz, ~] = min(zpos);    
    
    if maxidx < ceil(length(zpos)*0.1)
        outs = NaN(1,7);
        disp('This tracker does not appear to leave the substrate.');
    end
    
    % Is the maximum z-value the last value in the trajectory? If not, make
    % it so.
    if maxidx ~= length(zpos)
        zpos = zpos(1:maxidx);
        frames = frames(1:maxidx);
    end
    
    
%     midrange = ceil(range(zpos(zpos>minz))/2 + minz);   % Middle of the range
    midrange = ceil(range(zpos(zpos>minz))/2 + minz);   % Middle of the range
    [midz, mid_zidx] = min(abs(zpos - midrange));
    lowerflat = mode(zpos(1:mid_zidx));    
    
    max_extent = length(zpos) - mid_zidx;
    
    extent = 3;
    
    if extent > max_extent
        extent = max_extent;
    end
    
    dist_far_edge = length(zpos) - (mid_zidx+extent);
    while dist_far_edge < 0
        extent = extent - 1;
        dist_far_edge = length(zpos) - (mid_zidx+extent);
    end
    
    if length(zpos) >= 2*extent + 1
        Nframes = 2*extent + 1;
        zpos_for_fitting = zpos(mid_zidx-extent:mid_zidx+extent);
        frames_for_fitting = frames(mid_zidx-extent:mid_zidx+extent);
    else zpos_for_fitting = zpos;
        frames_for_fitting = frames;
        Nframes = length(zpos);
    end
    
    order = 1;

    if length(frames_for_fitting) < order + 2
        outs = NaN(1,7);
        return;
    end  
    
    fit = polyfit(frames_for_fitting, zpos_for_fitting, order);
    fitZ = polyval(fit, frames_for_fitting);
        
    firstframe = fit(1) * lowerflat + fit(2);
    Zvel = fit(1); % [stepsize/frame]
    ZfitRmse = sqrt(sum((zpos_for_fitting-fitZ).^2));
    ZposMean = mean(zpos_for_fitting);
    ZposRange = range(zpos_for_fitting);
    CVerr = ZfitRmse / ZposMean;
    
    outs = [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, CVerr, Nframes];    
    
    smooth_dzdt = CreateGaussScaleSpace(zpos, 1, 4) ./ mean(diff(frames));
    [maxdzdt, maxdzdt_idx] = max(smooth_dzdt);
    
    figure;
    hold on;
    plot(frames,             zpos,             'Marker', 'o', 'MarkerEdgeColor', [0.75 0.75 0.75], 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    plot(frames_for_fitting, zpos_for_fitting, 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineStyle', 'none');
    plot(frames_for_fitting, fitZ, 'Marker', 'x', 'MarkerEdgeColor', 'r', 'LineStyle', '-', 'Color', 'r');
    plot(frames(maxdzdt_idx), zpos(maxdzdt_idx), 'Marker', '^', 'MarkerSize', 16);
    plot(frames(mid_zidx), midrange, 'Marker', 'diamond', 'MarkerSize', 16);
    
    hold off;
    xlabel('Time [s]');
    ylabel('Zpos [um]');
    legend('zpos', 'UsedInFit', 'fit', 'max deriv.', 'midrange', 'Location','northwest');
    title(['trackerID = ' num2str(myID), ', CVerr= ', num2str(CVerr,'%2.2f')]);
    xlim([min(frames_for_fitting)-40*mean(diff(frames)) max(frames_for_fitting)+mean(diff(frames))]);
return

function outs = calcZvel_xyz(frames, trackerid, xpos, ypos, zpos, lowlim, highlim)

    myID = unique(trackerid);
    
%     [dx, dy, dz] = deal(diff(xpos), diff(ypos), diff(zpos));

    dxyz = diff([xpos(:), ypos(:), zpos(:)]);
    df = diff(frames(:));
    df = repmat(df, 1, 3);
    
    dxyzdf = dxyz./df;
    
    
     
    % Where is the minimum value
    [~, minidx] = min(zpos);
    
    zpos = zpos(minidx:end);
    frames = frames(minidx:end);
    
    
    % Choose how long the dataset needs to be before we consider it. If
    % it's too short, return NaN for this tracker.
    if length(zpos) < 10
        outs = NaN(1,7);
        disp('Not enough points to run algorithm.');
    end
    

%     if isempty(last)
%         frames = frames(first:end);
%         zpos = zpos(first:end);
%     else
%         frames = frames(first:last(1)-1);
%         zpos = zpos(first:last(1)-1);
%     end

    % Next, where is the maximum z for this tracker located? If a tracker
    % is moving down, it's not one we want to measure velocity for.
    % Consider drawing out this part of the process into a different
    % function.    
    [maxz, maxidx] = max(zpos);
    [minz, ~] = min(zpos);    
    
    if maxidx < ceil(length(zpos)*0.1)
        outs = NaN(1,7);
        disp('This tracker does not appear to leave the substrate.');
    end
    
    % Is the maximum z-value the last value in the trajectory? If not, make
    % it so.
    if maxidx ~= length(zpos)
        zpos = zpos(1:maxidx);
        frames = frames(1:maxidx);
    end
    
    
%     midrange = ceil(range(zpos(zpos>minz))/2 + minz);   % Middle of the range
    midrange = ceil(range(zpos(zpos>minz))/2 + minz);   % Middle of the range
    [midz, mid_zidx] = min(abs(zpos - midrange));
    lowerflat = mode(zpos(1:mid_zidx));    
    
    max_extent = length(zpos) - mid_zidx;
    
    extent = 3;
    
    if extent > max_extent
        extent = max_extent;
    end
    
    if mid_zidx <= extent
        extent = mid_zidx-1;
    end
    
    dist_far_edge = length(zpos) - (mid_zidx+extent);
    while dist_far_edge < 0
        extent = extent - 1;
        dist_far_edge = length(zpos) - (mid_zidx+extent);
    end
    
    if length(zpos) >= 2*extent + 1
        Nframes = 2*extent + 1;
        zpos_for_fitting = zpos(mid_zidx-extent:mid_zidx+extent);
        frames_for_fitting = frames(mid_zidx-extent:mid_zidx+extent);
    else zpos_for_fitting = zpos;
        frames_for_fitting = frames;
        Nframes = length(zpos);
    end
    
    order = 1;

    if length(frames_for_fitting) < order + 2
        outs = NaN(1,7);
        return;
    end  
    
    fit = polyfit(frames_for_fitting, zpos_for_fitting, order);
    fitZ = polyval(fit, frames_for_fitting);
        
    firstframe = fit(1) * lowerflat + fit(2);
    Zvel = fit(1); % [stepsize/frame]
    ZfitRmse = sqrt(sum((zpos_for_fitting-fitZ).^2));
    ZposMean = mean(zpos_for_fitting);
    ZposRange = range(zpos_for_fitting);
    CVerr = ZfitRmse / ZposMean;
    
    outs = [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, CVerr, Nframes];    
    
    smooth_dzdt = CreateGaussScaleSpace(zpos, 1, 4) ./ mean(diff(frames));
    [maxdzdt, maxdzdt_idx] = max(smooth_dzdt);
    
    figure;
    hold on;
    plot(frames,             zpos,             'Marker', 'o', 'MarkerEdgeColor', [0.75 0.75 0.75], 'MarkerFaceColor', 'none', 'LineStyle', 'none');
    plot(frames_for_fitting, zpos_for_fitting, 'Marker', 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'LineStyle', 'none');
    plot(frames_for_fitting, fitZ, 'Marker', 'x', 'MarkerEdgeColor', 'r', 'LineStyle', '-', 'Color', 'r');
    plot(frames(maxdzdt_idx), zpos(maxdzdt_idx), 'Marker', '^', 'MarkerSize', 16);
    plot(frames(mid_zidx), midrange, 'Marker', 'diamond', 'MarkerSize', 16);
    
    hold off;
    xlabel('Time [s]');
    ylabel('Zpos [um]');
    legend('zpos', 'UsedInFit', 'fit', 'max deriv.', 'midrange', 'Location','northwest');
    title(['trackerID = ' num2str(myID), ', CVerr= ', num2str(CVerr,'%2.2f')]);
    xlim([min(frames_for_fitting)-40*mean(diff(frames)) max(frames_for_fitting)+mean(diff(frames))]);
return

