% 3DFM function  
% Rheology 
% msd2pt DBH
% created 6-1-2004 
%  
% calculates the two particle correlation function

% lets try this in pieces

%filename = 'data_txy.dat'
M = load(filename);

% transpose the matrix

M_data = M';

% define the number of frames and the fps based on the 1st column

N_frames = length(M_data(1,:));

N_samples = (length(M_data(:,1))-1)/2;

fps = 1/mean(diff(M_data(1,:)))

%convert = 10^(-6); lets leave everything in micros for now


% now I can calculate the MSD just have I have done in other programs....

% define the window over which to calculate the MSD's
window = [1 3 7 10 30 70 100 300 700 1000];
size_window = length(window);

MSD = zeros(N_samples +1, size_window);

% defie tau

for k = 1:size_window,
    
    MSD(1,k) = window(k)/fps;
    
end


filename_save = strcat(filename,'msd_out.txt');
save(filename_save, 'MSD_out', '-ASCII');