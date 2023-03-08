function Vclr = Calculate_Velocity_ColorMap(vr, MinVelThresh)
    %
    % Mapping the logged-velocities to colors for scatter-point color-mapping
    %   
    % Obvious first steps:
    % 1. Get the magnitude of the velocity vectors 
    % 2. Set any NaN to zero.
    % 3. Take the log. We need to keep the original non-shifted logvr
    %    separate from the shifted/color-mapped ones    
    
    % Minimum velocity threshold in pixels per frame. It's a magic number.
    if nargin < 2 || isempty(MinVelThresh)
        MinVelThresh = 0.001;
    end
        
    vr(vr < MinVelThresh) = NaN;
    logvr = log10(vr);

    % Set any number that is set to -inf or NaN to the *non-infinite* minimum value.
    % We are just setting colors in the colormap. Anything with zero 
    % (or "less") velocity will just be black anyway. We need to keep the
    % original (non-infinite) non-shifted logvr separate from the 
    % shifted/color-mapped one.
    tst = isfinite(logvr);
    if sum(tst)>0
        logvr(~tst) = min(logvr(tst));
    else
        logvr(:,1) = zeros(size(tst));
    end
    
    % We want to normalize the velocities to the colormap, where 1 is the
    % highest colormap value and 0 the lowest. To do that we add the minimum
    % value. If that minimum value is negative, we'll subtract is out
    % anyway. Once this operation is over the minimum value should be zero
    % and the maximum value should be one.      
    lvr = logvr;
    lvr = lvr - min(lvr);   
    normvr = lvr ./ max(lvr);
   
    vals = floor(normvr * 255);
    
    
    if ~isnan(vals)
        heatmap = hot(256);
        Vclr = heatmap(vals+1,:);
    else
        Vclr = [0 0 0];
    end
    
    return