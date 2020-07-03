function outs = load_evtfile(filename, fps, calib_um)

    dd = load(filename);
    
    % What does the loaded evt file look like? Versions up until recently
    % encoded the output to look a lot like the vrpn file format just with
    % extra stuff. That's not really the way to do it, but for the purposes
    % of compatibility, load_evtfile can convert data to a newer consistent
    % format, with some degree of fidelity.
    video_tracking_constants;
    
    
    if isfield(dd.tracking, 'spot3DSecUsecIndexFramenumXYZRPY')
        trk = dd.tracking.spot3DSecUsecIndexFramenumXYZRPY;
    else 
        outs = [];
        return
    end

    if isfield(dd.tracking, 'calib_um')
        logentry('Overriding calib_um in function call with indiginous value in data file.')
        calib_um = dd.tracking.calib_um;
    elseif nargin < 3 || isempty(calib_um)
        calib_um = NaN;
    end

    if isfield(dd.tracking, 'fps')
        logentry('Overriding fps in function call with indiginous value in data file.');
        fps = dd.tracking.fps;
    elseif nargin < 2 || isempty(fps)
        fps = NaN;
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
    outs.calib_um = repmat(calib_um, size(zerocol));
    outs.Fps     = repmat(fps, size(zerocol));
    
    outs = struct2table(outs);
    
return

