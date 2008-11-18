function [table_out, drift_vectors] = varforce_remove_drift(table, params)
% VARFORCE_REMOVE_DRIFT finds zero volt regions in each sequence, estimates drift, and subtracts from sequence 
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/18/08 (krisford) 
%  
% finds zero volt regions in each sequence, estimates drift, and subtracts 
% it only from that sequence.  (uses remove_drift in 3dfmAnalysis).
%
%   [table_out] = varforce_remove_drift(table, params)
%
% where "table_out" is the outputted video_tracking_table with drift removed.
%       "table" is the input video tracking table with drift.
%       "params" is a structure containing the varforce metadata information.
%
   
    varforce_constants;

    logentry('Removing Drift...');

    for k = min(table(:,SEQ)) : max(table(:,SEQ))
        % reduce the data to the kth sequence
        idxS = find(table(:,SEQ) == k);
        my_seq = table(idxS,:);
        
        % determine the start and stop times for the drift section (i.e.
        % where the voltage is equal to zero.
        idxP = find(my_seq(:,VID) == 0);
        drift_pulse = my_seq(idxP,:);
        min_drift_time = min(drift_pulse(:,TIME));
        max_drift_time = max(drift_pulse(:,TIME));
        
        if size(my_seq,1) > 0  % don't remove drift if there's no data.
            [driftless_seq_table, drift_velocity] = remove_drift(my_seq, min_drift_time, max_drift_time, 'linear');
        end 
        
        if ~exist('table_out')
            table_out    = driftless_seq_table;
            drift_vectors = [drift_velocity(:,1), drift_velocity(:,3)];
        else
            table_out    = [table_out ; driftless_seq_table];
            drift_vectors = [drift_vectors; [drift_velocity(:,1), drift_velocity(:,3)]];
        end
    end

    return;

    
%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforce_remove_drift: '];
     
     fprintf('%s%s\n', headertext, txt);
     return
     
     
