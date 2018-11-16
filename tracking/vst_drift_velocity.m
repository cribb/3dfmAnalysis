function outs = vst_drift_velocity(DataIn)

    TT = join(DataIn.ComTable, DataIn.VidTable(:,{'Fid', 'Fps', 'Calibum'}));

    TT.Xcom = TT.Xcom .* TT.Fps .* TT.Calibum;
    TT.Ycom = TT.Ycom .* TT.Fps .* TT.Calibum;
    
    [g, gFid] = findgroups(TT.Fid);

    foo = splitapply(@(x1,x2,x3)mydxydt(x1,x2,x3), TT.Frame, TT.Xcom, TT.Ycom, g);


    outs.Fid = gFid;
    outs.Vx = foo(:,1);
    outs.Vy = foo(:,2);
    outs.Magv = foo(:,3);
    outs.Anglev = foo(:,4);
    
    outs = struct2table(outs);    
    
    outs.Properties.VariableUnits{'Vx'} = '[um/s]';
    outs.Properties.VariableUnits{'Vy'} = '[um/s]';
    outs.Properties.VariableUnits{'Magv'} = '[um/s]';
    outs.Properties.VariableUnits{'Anglev'} = '[rad]';
    outs.Properties.VariableDescriptions{'Anglev'} = 'range 0 - 2pi';
    
return



function driftvect = mydxydt(frame, x,y)

    idx = ~isnan(x);
    
    [mxfit,xfitinfo] = polyfit(frame(idx),x(idx),1);
    [myfit,yfitinfo] = polyfit(frame(idx),y(idx),1);

    driftvect(:,1) = mxfit(1);
    driftvect(:,2) = myfit(1);
    driftvect(:,3) = abs(mxfit(1) + 1i*myfit(1));
    driftvect(:,4) = angle(mxfit(1) + 1i*myfit(1))+pi;
    
return


