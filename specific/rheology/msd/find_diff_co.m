% 3DFM function  
% Rheology 
% find_diff_co 08/23/04
%
% DBH
%  
% This function finds the diffusion coefficient of a data set
% as a function of lag time
%  
%  

data = load(filename);

M_data = data';

% define the number of frames and the fps based on the 1st column

N_frames = length(M_data(1,:))

N_samples = (length(M_data(:,1))-1)

fps = 1/mean(diff(M_data(1,:)))

convert = 10^(-6);

%convert = 1;

% now I can calculate the MSD just have I have done in other programs....

window = [1 2 5 10 20 50 100 200 500 1000];
size_window = length(window);

diff_co = zeros(N_samples +1, size_window);


% defie tau

for k = 1:size_window,
    
    diff_co(1,k) = window(k)/fps;
  
    
end


for m = 1:N_samples,
    
    for k = 1:size_window,
        
        for j = 1:(N_frames - window(k)), % start frames loop
            
            r(j) = (M_data(m+1,j+window(k))*convert - M_data(m+1,j)*convert);
            
        end % end frames loop
        
        %hist(r);
        %diff_co(m+1, k) = var(r)
        %vr = var(r);
        diff_co(m+1, k) = var(r)/(2*window(k)/fps);
        %pause
        clear j;
        
        % need to fit data to dispeasion of curve
        
        
        
                %old%MSD(m+1, k) = mean(r2);
        
                %old%clear r2;
        
    end % end window loop
    
    clear k;
    
end % end samples loop

clear m;

diff_co_out = diff_co'

filename_save = strcat(filename,'diff_co.txt');
save(filename_save, 'diff_co_out', '-ASCII');