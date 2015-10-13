% VIDEO_TRACKING_CONSTANTS generates COLUMN CONSTANTS for video tracking data
%
% 3DFM function  
% Tracking 
% last modified 2015.06.05 (jcribb)
%   
% script that creates column constants for video tracking data matrix.
%
% NOTE: If memory issues occur because of too many columns, consider a
% change to the vrpnlog2mat software that will selectively choose
% *relevant* columns (e.g. not including ROLL PITCH and YAW when tracked
% objects are spheres and have no rotational moments).
%

    PANPASS   = 1;
    PANWELL   = 2;
    PANFRAME  = 3; 
    PANID     = 4;    
    PANX      = 5; 
    PANY      = 6; 
    PANAREA   = 7;
    PANSENS   = 8;
    
