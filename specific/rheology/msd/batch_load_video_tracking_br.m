% 3DFM function  
% Rheology 
% last modified 05/10/04 
%  
% batch_load_video_tracking_br 
% by DB Hill
% 
%  
%  [outputs] = writes file with position vs. time data for multiple beads
%  tracked in 2-D using video spot tracker
%   
%  Notes:  
%   
%  This function calls all *.mat files from within a given subfolder of
%  beads tracked in bright field with the 1.5x optivar in place on Hercules
%  using the Pulnix camera
%  
%
%  - created 3-2004
%  Last modified 5-10-2004 by dbh
%   
%  
% batch_load_video_tracking_br

% loading stuff


clear all
close all



fu = dir('*.mat');

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;

    
    d = load_video_tracking(filename, 120,[],[],'rectangle','um',0.104,'absolute');%1.5x
    %d = load_video_tracking(filename, 120,[],[],'rectangle','um',0.154);% 1.0x

    data = [d.video.time d.video.x d.video.y];

    filename_save_2 = strcat(filename,'_position.dat');
    save(filename_save_2, 'data', '-ASCII');

end