function Bdist = bead_dist(M);
% 3DFM function  
% Rheology 
% bead_dist.m
% DBH 6-11-2004
%
% This program finds the distances between each bead in a given sample
% and evolves the distance in time

%filename - ('');
% M = load(filename);

% transpose the matrix

M_data_bd = M';

% define the number of frames and the fps based on the 1st column

N_frames = length(M_data_bd(1,:));

N_samples = (length(M_data_bd(:,1))-1)/2

% create the number of data sets I'll need

if N_samples==1
    N_sampes
    pause
elseif N_samples==2
    N_data=1;
else
    m(1) = 0;
    for n=2:N_samples
        m(n) = m(n-1)+(n-1);
    end
    N_data = m(N_samples);
    clear n;
    clear m;
end % end if else loop

Data_out = zeros(N_data,N_frames);


for n=1:N_frames
    
    z = 1; % counter
    for p = 1:(N_samples-1)
        
        for q = (p+1):N_samples
            
            N_data(z,n) = sqrt((M_data_bd(p+1,n)-M_data_bd(q+1,n))^2+(M_data_bd(p+1+N_samples,n)-M_data_bd(q+1+N_samples,n))^2);
            
            z = z+1;
            
        end
        
    end
    
end

Bdist = N_data;
%Data_out = N_data';
%filename_save = strcat(filename,'bead_dist.txt');
%save(filename_save, 'Data_out', '-ASCII');
            
            