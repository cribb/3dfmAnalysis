% 3DFM function  
% Rheology 
% last modified 06/20/03 
%  
% msd_1d 
% by DBH
% 
%  
%  [outputs] = writes file with tau and mean squared displacement data
%   
%  Notes:  
%   
%  This function is intended to be ran as part of a batch file
%  that will calculate the the msd's of all beads in a given postion 
%  vs. time data set (usually written in batch_load_video_tracking) 
%  This program is set up to handle 1-D tracks only 
%
%  - created 3-2004
%  Last modified 5-10-2004 by dbh
%   
%  
% msd_2d
% pass fileaname to the program from outside

filename = 'tx.dat';
M = load(filename);

% transpose the matrix

M_data = M';

% define the number of frames and the fps based on the 1st column

N_frames = length(M_data(1,:));


N_samples = (length(M_data(:,1))-1);

%fps = 1/mean(diff(M_data(1,:)))
fps = 100;

convert = 1;

% now I can calculate the MSD just have I have done in other programs....

window = [1 3 7 10 30 70 100 300 700 1000];
size_window = length(window);

MSD = zeros(N_samples +1, size_window);

% defie tau

for k = 1:size_window,
    
    MSD(1,k) = window(k)/fps;
    
end


for m = 1:N_samples,
    
    m
    
    for k = 1:size_window,
        
        
        
        for j = 1:(N_frames - window(k)), % start frames loop
            
            r2(j) = (M_data(m+1,j+window(k))*convert - M_data(m+1,j)*convert)^2;
            
        end % end frames loop
        
        clear j;
        
        MSD(m+1, k) = mean(r2);
        
        clear r2;
        
    end % end window loop
    
    clear k;
    
end % end samples loop

clear m;

MSD_out = MSD';

filename_save = strcat(filename,'msd_out.txt');
save(filename_save, 'MSD_out', '-ASCII');