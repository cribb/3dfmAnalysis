function offset = dmbr_find_offsets(vidtable, params)
% 3DFM function   
% Rheology
% last modified 03/21/08 (jcribb)
%  

    dmbr_constants;

    cols = [TIME X Y Z ROLL PITCH YAW J SX SY SJ DX DY DJ SDX SDY SDJ];

    offset = vidtable(1, cols);

%     % this removes the offsets sequence by sequence
%     vidtable(:, cols) = vidtable(:,cols) - repmat(offset, size(vidtable,1), 1);
% 
%     out = vidtable;

