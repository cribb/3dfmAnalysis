function d = bead_force_stokes_jac(filelist, fps, calibum, bead_diameter_um, std_viscosity_Pas, width, height, lolim, hilim)
% how this works

if nargin < 9 || isempty(hilim)
    hilim = 250;
end

if nargin < 8 || isempty(lolim)
    lolim = 52;
end

if nargin < 7 || isempty(height)
    height = NaN;
end

if nargin < 6 || isempty(width)
    width = NaN;
end

if nargin < 5 || isempty(std_viscosity_Pas)
    std_viscosity_Pas = 0;
end

if nargin < 4 || isempty(bead_diameter_um)
    bead_diameter_um = 24;   
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

BeadDiameter = repmat(bead_diameter_um, N, 1);
StdViscosity = repmat(std_viscosity_Pas, N, 1);
VidWidth = repmat(width, N, 1);
VidHeight = repmat(height, N, 1);

d.VidTable = mk_video_table(filelist, fpslist, calibumlist, width, height, [], []);

% AUGMENT standard table
Augs = table(BeadDiameter, StdViscosity, VidWidth, VidHeight);
d.VidTable = [d.VidTable Augs];
d.VidTable.Properties.VariableUnits{'BeadDiameter'} = 'um';
d.VidTable.Properties.VariableUnits{'StdViscosity'} = 'Pa s';

d.TrackingTable = vst_load_tracking(d.VidTable);

jTable = join(d.TrackingTable(:,{'Fid', 'Frame', 'ID', 'Z', 'Radius', 'CenterIntensity', 'Sensitivity'}), ...
              d.VidTable(:,{'Fid', 'Fps', 'Calibum'}));

jTable.Z = jTable.Z .* jTable.Calibum; % [stepsize] -> [um]
jTable.Properties.VariableUnits{'Z'} = 'um';

jTable.Time = jTable.Frame ./ jTable.Fps; % [frame #] -> [sec]
jTable.Properties.VariableUnits{'Time'} = 's';

[g, grpTable] = findgroups(jTable(:,{'Fid', 'ID'}));

tmpVels = splitapply(@(x1,x2)calcZvel(x1, x2, lolim, hilim), ...
                    jTable.Time, ...
                    jTable.Z, ...
                    g);

T.FirstTime = tmpVels(:,1);
T.Zvel      = tmpVels(:,2);
T.ZfitRmse  = tmpVels(:,3);
T.ZposMean  = tmpVels(:,4);
T.ZposRange = tmpVels(:,5);
T.CVerr     = tmpVels(:,6);

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

% figure; 
% gscatter(jTable.Time, jTable.Z, g);
% xlabel('Time [s]');
% ylabel('Z pos [um]');
% 
% 
% figure;
% gscatter(jTable.Time, CreateGaussScaleSpace(jTable.Z, 1, 8).*jTable.Fps, g);
% xlabel('Time [s]');
% ylabel('Z velocity [um/s], s=8');

return

function outs = calcZvel_jac(frames, zpos, lowlim, highlim)

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


function outs = calcZvel(frames, zpos, lowlim, highlim)

    first = find(zpos >  lowlim, 1);
    last  = find(zpos > highlim, 1);
    
    if isempty(last)
        frames = frames(first:end);
        zpos = zpos(first:end);
    else
        frames = frames(first:last-1);
        zpos = zpos(first:last-1);
    end
    
    fit = polyfit(frames, zpos, 1);
    fitZ = polyval(fit, frames);
    
    firstframe = frames(1);
    Zvel = fit(1); % [stepsize/frame]
    ZfitRmse = sqrt(sum((zpos-fitZ).^2));
    ZposMean = mean(zpos);
    ZposRange = range(zpos);
    CVerr = ZfitRmse / ZposMean;
    
    outs = [firstframe, Zvel, ZfitRmse, ZposMean, ZposRange, CVerr];
    
    figure;
    plot(frames, zpos, 'ko', frames, fitZ, 'r-');
    xlabel('Time [s]');
    ylabel('Zpos [um]');
    
return
