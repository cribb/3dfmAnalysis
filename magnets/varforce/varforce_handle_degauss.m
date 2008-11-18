function [tableout, rem_Ftable] = varforce_handle_degauss(table, params);
% VARFORCE_HANDLE_DEGAUSS estimates remanence force in pre-degauss regions to get velocity 
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%  
% finds zero volt regions in each sequence, estimates remanence force
% in pre-degauss regions via a linear fit to get the velocity.  Remanence
% is computed for each pre-degauss region in each sequence for each bead
% separately.  After the remanence is computed, the pre-degauss regions of
% the zero volt pulse is removed from the data matrix.  Presumably any
% drift remaining after degauss is due to sample drift and not due to
% remanent magnetization.
%
%   [table_out] = varforce_handle_degauss(table, params)
%
% where "table_out" is the outputted video_tracking_table with pre-degauss
%                   regions removed.
%       "remtable" is the computed remanence information matrix.
%       "table" is the input video tracking table with drift.
%       "params" is a structure containing the varforce metadata information.
%

    % constants describing headers for varforce's raw datatable
    varforce_constants;

    buffer = 1;
 
    %  extract remanence info
    REMidx = find(table(:,DEGAUSS) == 0);
    rem_Ftable = table(REMidx,:);
    rem_Ftable = varforce_remove_buffer_points(rem_Ftable, buffer);

    % cut out data in zero pulse that occured before degauss funtion
    tableout = table;
    tableout(REMidx,:) = [];
    
    % compute remanence estimates here

    
return
