function dataout = pan_process_CellExpt(filepath, exityn)
% pan_CellProcessingScript
%Wrapper for CellProcessingScript that runs the CellProcessingScript and
%exits for use inside PanopticNerve.

if nargin < 2 || isempty(exityn)
    exityn = 'n';
end

cd(filepath);

metadata = pan_load_metadata(filepath, '96well');
dataout  = pan_analyze_CellExpt(filepath);
dataout  = pan_publish_CellExpt(metadata);


if exityn == 'y'
    exit;
end

return;
