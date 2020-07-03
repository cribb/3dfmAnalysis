function outs = load_evtfile(filename, fps, calibum)

    dd = load(filename);
    
    % What does the loaded evt file look like? Versions up until recently
    % encoded the output to look a lot like the vrpn file format just with
    % extra stuff. That's not really the way to do it, but for the purposes
    % of compatibility, load_evtfile can convert data to a newer consistent
    % format, with some degree of fidelity.
    video_tracking_constants;
    
    
    if isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        trk = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;

    if isfield(dd.tracking, 'calibum')
        logentry('Overriding calibum in function call with indiginous value in data file.')
        calibum = dd.tracking.calib_um;
    end

    if isfield(dd.tracking, 'fps')
        logentry('Overriding fps in function call with indiginous value in data file.');
        fps = dd.tracking.fps;
    end

        if ischar(fps)
            fps = str2double(fps);
        end
        
        zerocol = zeros(size(trk,1), 1);
        
        outs.Frame = trk(:,FRAME);
        outs.ID = trk(:,ID);
        outs.X = trk(:,X);
        outs.Y = trk(:,Y);
        outs.Z = trk(:,Z);
        outs.Radius = zerocol;
        outs.CenterIntensity = zerocol;
        outs.Orientation_ifMeaningful_ = zerocol;
        outs.Length_ifMeaningful_= zerocol;
        outs.FitBackground_forFIONA_= zerocol;
        outs.GaussianSummedValue_forFIONA_= zerocol;
        outs.MeanBackground_FIONA_    = zerocol;
        outs.SummedValue_forFIONA_    = zerocol;
        outs.RegionSize    = zerocol;
        outs.Sensitivity    = zerocol;
        outs.ForegroundSize= zerocol;
        outs.Calibum = repmat(calibum, size(zerocol));
        outs.Fps     = repmat(fps, size(zerocol));
        
    else
        outs = [];
    end    
    
    outs = struct2table(outs);
    
%     
%                                 info: NaN
%                             calib_um: 1
%                                  fps: '1'

return

