function d = batch_msd_2d(text);
% 3DFM function  
% Rheology 
% last modified 05/10/04 
%  
% batch_msd_2d_d 
% by DB Hill
% 
%  d = batch_msd_2d(text);
%
%  where text is the suffix of all the files you wish to run msd
%  calculation upon
% 
%  [outputs] = none directly, calls msd_2d whichs writes tau and MSD info
%  for multiple beads
%   
%  Notes:  
%   
%  This funtion is a wrapper calling msd_2d for all drift-corrected
%  position vs. time files in a given subfolder. This program is oftern ran
%  as part of batch_drift_br or batch_drift_fl
%  
%
%  - created 3-2004
%  Last modified 5-10-2004 by dbh
%   
%  
% batch_msd_2d_d

fu = dir(text);

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;

    msd_2d(filename);

end

d = z;