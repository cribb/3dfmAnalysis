% batch_find_diff_co

fu = dir('*t.dat');

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;

    find_diff_co;

end


% merge the data

clear all
close all

filename_save = 'diff_co_all.txt';

fu = dir('*o.txt');

num_files = size(fu);

%C = zeros(1,10);

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
