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
clear all
close all

fu = dir('*t.dat');

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;
    data = load(filename);

    M_data = data';

    % define the number of frames and the fps based on the 1st column

    N_frames = length(M_data(1,:))

    N_samples = (length(M_data(:,1))-1)

    fps = 1/mean(diff(M_data(1,:)))

    convert = 10^(-6);



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
        
            diff_co(m+1, k) = var(r)/(2*window(k)/fps);
        
            clear j;
        
        end % end window loop
    
        clear k;
    
    end % end samples loop

    %--- need to take diff_co's into one matrix for saving
    
    
    diff_co_t = diff_co';
    size_m = length(diff_co_t(1,:));
    
    if z == 1;
        
        C = diff_co_t;
    else
        size_c = length(C(1,:));        
        for j = 2:size_m
 
            C(:,size_c+j-1) = diff_co_t(:,j);
                        
        end % end j for
        
    end % end if/else

    

end% end files loop






%---- wait until the end to save the file-----%
%filename_save = strcat(filename,'diff_co.txt');
save('Diff_co_all.txt', 'C', '-ASCII');