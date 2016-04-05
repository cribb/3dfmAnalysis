function msdout = msdtime(vidtable)


    video_tracking_constants;

    trackerIDs = unique(vidtable(:,ID))';
    Ntrackers = length(trackerIDs);
    Nframes = max(vidtable(:,FRAME));

    idx = vidtable(:,FRAME) == Nframes;   
    frame_rate = Nframes / mean(vidtable(idx, TIME ));
    
    t = [0:Nframes]' .* 1/frame_rate;
    
    xdata = NaN( Nframes, length(trackerIDs) );
    ydata = xdata;
    
    for k = 1:Ntrackers
        myID = trackerIDs(k);
        
        mydata = get_bead( vidtable, myID );
        npoints = size(mydata,1);
        
        xdata(1:npoints, k) = mydata(:,X);
        ydata(1:npoints, k) = mydata(:,Y);
    end
    
    position_zero_x = xdata(1,:);
    position_zero_y = ydata(1,:);
    
    x_sqdiff = (xdata - repmat(position_zero_x(1,:), Nframes+1, 1)) .^ 2;
    y_sqdiff = (ydata - repmat(position_zero_y(1,:), Nframes+1, 1)) .^ 2;
    
    msdout.t = t;
    msdout.x = x_sqdiff;
    msdout.y = y_sqdiff;
    msdout.xmean = nanmean(x_sqdiff, 2);
    msdout.ymean = nanmean(y_sqdiff, 2);
    msdout.xstd = nanstd(x_sqdiff, [], 2);
    msdout.ystd = nanstd(y_sqdiff, [], 2);
    
    return;
    
    
    