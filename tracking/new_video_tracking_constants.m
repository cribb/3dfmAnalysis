% NEW_VIDEO_TRACKING_CONSTANTS generates COLUMN CONSTANTS for video tracking data
%
% 3DFM function  
% Tracking 
% last modified 2017.12.08 (jcribb)
%   
% script that creates column constants for video tracking data matrix.
%
% NOTE: If memory issues occur because of too many columns, consider a
% change to the vrpnlog2mat software that will selectively choose
% *relevant* columns (e.g. not including ROLL PITCH and YAW when tracked
% objects are spheres and have no rotational moments).
%

    FID      = 1;
    ID       = 2; 
    FRAME    = 3; 
    X        = 4; 
    Y        = 5; 
    AREA     = 6;
    SENS     = 7;
    CENTINTS = 8;
    
    NULLTRACK = zeros(0,8);
    
    
    