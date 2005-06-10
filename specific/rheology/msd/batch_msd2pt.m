function d = batch_msd2pt(win,text);
% 3DFM function  
% Rheology 
% batch_msd2pt()
% created 11-18-2004
%  
% This function calculates the 2pt correlation function of beads in multiple files
%
% d = batch_msd2pt(win,text);
%   
%  where "win" is the window to be use
%       win = 2: window takes log steps between 1 and 200
%       all others, window takes log steps between 1 and 1000
%  "text" is a char string that is used to call files of *.txt or *.dat or
%       others
%  output: writes data to file 'msd2pt.txt' of the form
%   
%   0   t1  t2  t3  t4  t5  t6  t7  t8  t9  t10 0
%   r1  dr1 dr1 dr1 dr1 dr1 dr1 dr1 dr1 dr1 dr1 N_beads at r1
%   r2  dr2 dr2 dr2 dr2 dr2 dr2 dr2 dr2 dr2 dr2 N_beads at r2
%   etc.....
% where t1 == tau_1, and dr1 == the sum of the individual bead correctaions
% at a given separation (r1, r2...) At this point, the final statics will
% need to be calculated in excel or the like, because I am mindful of not
% having all of the data in the same folder.

    

    fi = dir(text)
    num_files = size(fi);


    for z = 1:num_files,
    
        filename = fi(z).name
        e = msd2pt(filename,win);
    
        if z == 1;
        
            f = e.binned;
    
        else
        
            f(2:end,2:end) = f(2:end,2:end)  + e.binned(2:end,2:end);
        
        end

    end
    
    save('msd2pt_data.txt','f','-ASCII');