% data_merger
% DBH 4-7-03
% combines multiple files contanting MSD data into one file


clear all
close all

filename_save = 'sweep.txt';

fu = dir('*.txt');

num_files = size(fu);


size_c = 0;
for z = 1:num_files,
    
    filename = fu(z).name;
    M = load(filename);
    size_m1 = length(M(1,:));
    size_m2 = length(M(:,1));
    z

        
    for j = 1:2,
        for q = 1:size_m2,
               
            C(q,size_c+j) = M(q,j);
            
            
        end % end j for
        
    end % end if/else

    size_c = length(C(1,:));
end

save(filename_save, 'C', '-ASCII');
