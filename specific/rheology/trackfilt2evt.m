function outs = trackfilt2evt(filelist, fps)

    video_tracking_constants;

    filt.min_frames      = 0;
    filt.min_pixels      = 0;
    filt.max_pixels      = Inf;
    filt.max_region_size = Inf;
    filt.min_sens        = 0;
    filt.tcrop           = 0;
    filt.xycrop          = 0;
    filt.xyzunits        = 'pixels';
    filt.calib_um        = 1;
    filt.drift_method    = 'center-of-mass';
%     filt.drift_methodd   = 'linear';

    filelist = dir(filelist);

    if isempty(filelist)
        error('File not found.');
    end

for k = 1:length(filelist)

    d = load_video_tracking(filelist(k).name, fps, 'pixels', 1, 'absolute', 'no', 'matrix');
    d = filter_video_tracking(d, filt);
    
    if k==1
        newd = NaN(0, size(d,2));
    elseif k > 1 
        idmax = max(newd(:,ID));
        d(:,ID) = d(:,ID) + idmax;
    end

    newd = [newd; d];
end

    d_out = newd;

    if length(filelist) > 1
        outfile = 'multiple_files';
    else
        outfile = strrep(filelist(1).name, '.csv', '');
        outfile = strrep(outfile, '.mat', '');
        outfile = strrep(outfile, '.vrpn', '');
        outfile = strrep(outfile, '.evt', '');
    end
    
    outfile = [outfile '.evt.mat'];
    
    save_evtfile(outfile, d_out, 'pixels', 1, fps, 'mat');
    
    outs = d_out;
    
    return