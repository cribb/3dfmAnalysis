
% 3DFM Analysis
% Magnetics/varforce
% last modified 08/01/06
%  
% script that creates column constants for varforce calibration raw data
% matrix.  The raw data for the varforce calibration is derived from the
% video tracking data obtained from load_video_tracking.  It makes sense to
% keep the same 2D tabular matrix and add additional columns for pulse
% voltage (PULSE), sequence identification (SEQ), and zero-volt translation
% data taken *after* a degauss routine (DEGAUSS).
%

    % the column headings should initially be the same as video tracking
    % since we want all of that information in addition to the new
    % columns/labels.
    video_tracking_constants;
    
    % new columns/labels.
    PULSE  = 11;
    SEQ    = 12;
    DEGAUSS= 13;