function dataout = pan_process_CellExpt(filepath, systemid, exityn)
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

metadata = pan_load_metadata(filepath, '96well');

% create the 'window' vector that will decide which time scales (taus) we're going to use    
duration = metadata.instr.seconds;
frame_rate = metadata.instr.fps_bright;

window = 35;
window = unique(floor(logspace(0,round(log10(duration*frame_rate)), window)));
window = window(:);
metadata.window = window;

% setting up filter structure
filt.tcrop      = 3;
filt.min_frames = 10;
filt.min_pixels = 0;
filt.max_pixels = Inf;
filt.xycrop     = 0;
filt.xyzunits   = 'pixels';
filt.dead_spots = [0 392 28 32];   % flea2 on Monoptes camera after cleaning 2012/11/28


dataout  = pan_analyze_CellExpt(filepath, filt, systemid);
dataout  = pan_publish_CellExpt(metadata, filt);


if exityn == 'y'
    exit;
end

return;
