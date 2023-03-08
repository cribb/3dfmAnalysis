function VelocityTable = vst_CalculateVelocity(TrackingTable, smooth_factor)
% Outputs the velocities in the default format, which is [pixels/frame] and
% leaves the scaling to the invidual functions as needed.


    VelocityTable = vst_initVelocityTable;
    
    if nargin < 2 || isempty(smooth_factor)        
        smooth_factor = 1;
        logentry('No smoothness factor. Using 1 as a default.');
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


