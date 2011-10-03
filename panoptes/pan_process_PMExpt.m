function dataout = pan_process_PMExpt(filepath, exityn)
% pan_CellProcessingScript
%Wrapper for CellProcessingScript that runs the CellProcessingScript and
%exits for use inside PanopticNerve.

if nargin < 2 || isempty(exityn)
    exityn = 'n';
end

cd(filepath);

metadata = pan_load_metadata(filepath, '96well');

duration = metadata.instr.seconds;
frame_rate = metadata.instr.fps_bright;

% create the 'window' vector that will decide which time scales (taus) we're going to use    
window = 35;
window = unique(floor(logspace(0,round(log10(duration*frame_rate)), window)));
window = window(:);
metadata.window = window;


dataout  = pan_analyze_PMExpt(filepath);
dataout  = pan_publish_PMExpt(metadata);


if exityn == 'y'
    exit;
end

return;
