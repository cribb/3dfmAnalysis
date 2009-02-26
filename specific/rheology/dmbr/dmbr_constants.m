
% 3DFM Analysis
% Magnetics/dmbr
% last modified 08/01/06
%  
% script that creates column constants for dmbr raw data matrix, of which   
% the raw data is the varforce data matrix and is derived from this and the
% video tracking data obtained from load_video_tracking.  It makes sense to
% keep the same 2D tabular matrix and add additional columns for pulse
% voltage (VOLTS), sequence identification (SEQ), and zero-volt translation
% data taken *after* a degauss routine (DEGAUSS).
%

    % the column headings should initially be the same as video tracking
    % since we want all of that information in addition to the new
    % columns/labels.
    video_tracking_constants;
    
    % new columns/labels.
    VOLTS  = 11;
    SEQ    = 12;
    DEGAUSS= 13;
    
    FORCE  = 14;
    FERR_H = 15;
    FERR_L = 16;
    
    % Creep Compliance at time points
    J      = 17;        

    % Scale space zeroth derivative (smoothed displacments)
    SX     = 18;
    SY     = 19;
    SJ     = 20;
    
    % Scale space first derivative (unsmoothed velocity)
    DX     = 21;
    DY     = 22;
    DJ     = 23;

    % Scale space first derivative (smoothed velocity/viscosity)
    SDX    = 24;
    SDY    = 25;
    SDJ    = 26;
    
    
