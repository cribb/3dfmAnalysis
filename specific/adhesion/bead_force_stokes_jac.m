function d = bead_force_stokes_jac(filelist, fps, calibum, width, height, lolim, hilim)

filelist = dir(filelist);
filelist = {filelist.name};

N = length(filelist);

fpslist = repmat(fps, N, 1);
calibumlist = repmat(calibum, N, 1);

d.VidTable = mk_video_table(filelist, fpslist, calibumlist, width, height, [], []);
d.TrackingTable = vst_load_tracking(d.VidTable);

[g, gTable] = findgroups(d.TrackingTable.ID);

foo = splitapply(@(x1,x2)calcZvel(x1, x2, lolim, hilim), d.TrackingTable.Frame, d.TrackingTable.Z, g);

figure; gscatter(d.TrackingTable.Frame, d.TrackingTable.Z, g);

return



function outs = calcZvel(frames, zpos, lolim, hilim)
    
    uZ = unique(zpos);

    targetZ = mean(uZ) - 0.5*std(uZ);
    [~,pos_targetZ] = min(abs(zpos-targetZ));

    x = frames(pos_targetZ:end);
    y = zpos(pos_targetZ:end);
    
    [coef, stat] = polyfit(x(:), y(:), 1);
    
%     outs = {x, y, coef};
    outs = coef; %[coef, stat.normr];

return