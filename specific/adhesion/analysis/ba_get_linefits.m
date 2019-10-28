function m = ba_get_linefits(evtfile, calibum, visc_Pas, bead_diameter_um, Fid)

d = load_evtfile(evtfile);

t = d.FrameNumber ./ d.Fps;

[g, ID] = findgroups(d.SpotID);

if isempty(g)
    m = struct;
    return
end

foo = splitapply(@(x,y)mylinfit(x,y,1), t, d.Z, g);
sp = splitapply(@(x,y)get_startpos(x,y), d.X, d.Y, g);

mb = cell2mat(foo(:,3));

m.Fid = repmat(Fid, size(foo,1), 1);
m.Filename = repmat(string(evtfile), size(foo,1), 1);
m.SpotID = ID;
m.StartPosition = cell2mat(sp);
m.Pulloff_time = cell2mat(foo(:,1));
m.Mean_time = cell2mat(foo(:,2));
m.Mean_vel = mb(:,1) * calibum * 1e-6;
m.Force = 6 * pi * visc_Pas * bead_diameter_um/2 * 1e-6 * m.Mean_vel;

m = struct2table(m);

return

function outs = get_startpos(x,y)
    outs{1,1} = x(1);
    outs{1,2} = y(1);
return

function outs = mylinfit(x,y,order)
    mb = polyfit(x,y,order);
    outs{1,1} = x(1);
    outs{1,2} = mean(x);
    outs{1,3} = mb;
return
