% data_merger
% DBH 4-7-03
% combines multiple files contanting MSD data into one file


clear all
close all

filename_save = 'MSD_all.txt';

fu = dir('*.txt');

num_files = size(fu);



for z = 1:num_files,
    
    filename = fu(z).name;
    M = load(filename);
    size_m = length(M(1,:));
    z
        
    if z == 1;
        
        C = M;
    else
        size_c = length(C(1,:));        
        for j = 2:size_m
 
            C(:,size_c+j-1) = M(:,j);
                        
        end % end j for
        
    end % end if/else

end

save(filename_save, 'C', '-ASCII');
