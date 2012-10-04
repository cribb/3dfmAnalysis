function dataout = pan_process_PMExpt(filepath, systemid, exityn)
% pan_CellProcessingScript
%Wrapper for CellProcessingScript that runs the CellProcessingScript and
%exits for use inside PanopticNerve.

if nargin < 2 || isempty(systemid)
    systemid = 'monoptes';
end

if nargin < 3 || isempty(exityn)
    exityn = 'n';
end

cd(filepath);

metadata = pan_load_metadata(filepath, systemid, '96well');

duration = metadata.instr.seconds;
frame_rate = metadata.instr.fps_bright;

% create the 'window' vector that will decide which time scales (taus) we're going to use    
window = 35;
window = unique(floor(logspace(0,round(log10(duration*frame_rate)), window)));
window = window(:);
metadata.window = window;

% setting up filter structure
filt.tcrop      = 3;
filt.min_frames = 20;
filt.min_pixels = 0;
filt.max_pixels = Inf;
filt.xycrop     = 0;
filt.xyzunits   = 'pixels';
% filt.dead_spots = [492 128 30 30 ; ...
%                    184 359 30 30 ; ...
%                    499 319 30 30 ; ...
%                    216 149 30 30 ];    % flea2 camera deadspots on 2011/10/07
filt.dead_spots = [0 0 0 0];
filt.drift_method = 'center-of-mass';


dataout  = pan_analyze_PMExpt(filepath, filt, systemid);
dataout  = pan_publish_PMExpt(metadata, filt);


if exityn == 'y'
    exit;
end

return;
