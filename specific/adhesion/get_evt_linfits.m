function m = get_evt_linfits(evtfile)

d = load_evtfile(evtfile);

t = d.FrameNumber ./ d.Fps;

[g, ID] = findgroups(d.SpotID);

foo = splitapply(@(x,y)mylinfit(x,y,1), t, d.Z, g);

m.SpotID = ID;
m.Velocity = foo(:,1);

m = struct2table(m);

return

function outs = mylinfit(x,y,order)

    outs = polyfit(x,y,order);

return