    % drift buster

clear all
close all

% set up a for loop here and see if we can make this much faster

fu = dir('*n.dat');

num_files = size(fu);


for z = 1:num_files
    
    

    d = load(fu(z).name);
    e(:,1) = d(:,1);
    endpt = length(d(1,:));

    % fit a line to each set and bust the drift

    
    for q = 2:endpt
        fit = polyfit(d(:,1),d(:,q),1);

        e(:,q) = d(:,q)-fit(1)*d(:,1)-fit(2);
        
    end
    
    



    % save the output

    filename_save = strcat(fu(z).name,'_nodrift.dat')
    save(filename_save,'e','-ascii');
    clear d;
    clear e;
    
end % end program and hope its all cool

