function m = get_evt_linfits(evtfile)

d = load_evtfile(evtfile);

t = d.FrameNumber ./ d.Fps;

[g, ID] = findgroups(d.SpotID);

foo = splitapply(@(x,y)mylinfit(x,y,1), t, d.Z, g);

mb = cell2mat(foo(:,3));

m.SpotID = ID;
m.Pulloff_time = cell2mat(foo(:,1));
m.Mean_time = cell2mat(foo(:,2));
m.Mean_vel = mb(:,1);

m = struct2table(m);

return

function outs = mylinfit(x,y,order)

    mb = polyfit(x,y,order);
    outs{1,1} = x(1);
    outs{1,2} = mean(x);
    outs{1,3} = mb;
    
return