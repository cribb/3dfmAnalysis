% 3DFM function  
% Rheology 
% last modified 05/10/04 
%  
% batch_msd_2d_d 
% by DB Hill
% 
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

clear all
close all



fu = dir('*t.dat');

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;

    msd_2d;

end