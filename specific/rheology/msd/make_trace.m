% 3DFM function  
% Rheology 
% make_trace DBH
% created 6-1-2004 
%  
% This function makes xy trace plots of bead diffusion data sets
% 

clear all
close all

% set up file name swapper
fu = dir('*.dat');

num_files = size(fu);

for n = 1:num_files
    
    filename = fu(n).name;
    
    M = load(filename, '-ascii');
    
    col = length(M(1,:));
    num_beads = (col -1)/2;
    
    h = figure;
    
    if num_beads<2
            q = 1;
        elseif num_beads<5
                q = 2;
            elseif num_beads<10
                    q = 3;
                elseif num_beads<17
                        q = 4;
                    elseif num_beads<26
                            q = 5;
                        elseif num_beads<37
                                q = 6;
                            else q = 7;
                            end
                            
   
    for p = 1:num_beads
        %subplot(1,num_beads,p), plot(M(:,p+1),M(:,p+1+num_beads))
        subplot(q,q,p), plot(M(:,p+1),M(:,p+1+num_beads))
    end
    
    % save the plot somehow
    
    filename_save = strcat(filename,'_plots.jpg');
    saveas(h,filename_save);
    close
    
end % end num_files for loop