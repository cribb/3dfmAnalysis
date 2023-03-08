function VelocityTable = vst_CalculateVelocity(TrackingTable, smooth_factor)
% Outputs the velocities in the default format, which is [pixels/frame] and
% leaves the scaling to the invidual functions as needed.


    VelocityTable = vst_initVelocityTable;
    
    if nargin < 2 || isempty(smooth_factor)
        smooth_factor = 1;
    end
    
    if isempty(TrackingTable)     
        logentry('TrackingTable is empty. Returning empty VelocityTable.');
        return
    end
    
    [g, gT] = findgroups(TrackingTable.Fid, TrackingTable.ID);    
            
    if ~isempty(g)
        Vel = splitapply(@(x1,x2,x3,x4){vst_CalcVel(x1,x2,x3,x4,smooth_factor)}, ...
                                                              TrackingTable.Fid, ...            
                                                              TrackingTable.ID, ...
                                                              TrackingTable.Frame, ...
                                                             [TrackingTable.X, ...
                                                              TrackingTable.Y, ...
                                                              TrackingTable.Z], ...
                                                              g);
        Vel = cell2mat(Vel);
    else
        Vel = NaN(0,5);
    end
        
    VelTable.Fid   = Vel(:,1);
    VelTable.ID    = Vel(:,2);
    VelTable.Frame = Vel(:,3);
    VelTable.Vx    = Vel(:,4);
    VelTable.Vy    = Vel(:,5);
    VelTable.Vz    = Vel(:,6);
    VelTable.Vr    = calculate_mag(Vel(:,4:6));
    VelTable.Vtheta = calculate_angle(Vel(:,4:6));
    VelTable.Vclr = Calculate_Velocity_ColorMap(VelTable.Vr);
    
    VelocityTable = struct2table(VelTable);    
         
    
return


function outs = vst_CalcVel(fid, id, frame, xyz, sfactor)    
    if isempty(frame)
        outs = zeros(0,3);
        return
    end
    
    dxyz = CreateGaussScaleSpace(xyz,1,sfactor);
    outs = [fid, id, frame, dxyz];
return


function mag = calculate_mag(matrix)
    mag = sqrt( sum( matrix.^2, 2 ) );
%     mag = vecnorm(matrix, 2, 2);
    
    
return


function angle = calculate_angle(matrix)
    angle = atan2(-matrix(:,2), matrix(:,1));    
return

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
