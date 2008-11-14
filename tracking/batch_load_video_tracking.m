function d = batch_load_video_tracking(text, lens, multiplier, fr, rel)
% BATCH_LOAD_VIDEO_TRACKING Load several video tracking datasets at once.
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
%  
% batch_load_video_tracking
% by DB Hill
% 
% d = batch_load_video_tracking(text, lens, multiplier, fr, rel)
%
%   text == suffix of filenames to load from pix's to UM's;
%
%   lens = 40 or 60x on artimus or hercules
%
%   multiplier = 1 or 1.5, depending on the optivar
%
%   rel == a string that sets the postion coordnates to be either relative
%       (starting from zero) or absolut
%  
%  [outputs] = writes file with position vs. time data for multiple beads
%  tracked in 2-D using video spot tracker. Outputs data in the form:
%  time x_1 x_2 x_3 .... y_1 y_2 y_3 .... 
%   
%  Notes:  
%   
%  This function calls all *.mat files from within a given subfolder of
%  beads tracked in fluorescences with the 1.0x optivar in place on Hercules
%  or artimus using the Pulnix camera
%  
%
% ***********************************************************************

video_tracking_constants;

% create and array with the filenames of a given suffix. For this program,
% they must include *.mat
fu = dir(text);

% count the number of files to be loaded
num_files = size(fu);

% calculate the conversion factor for pixels -- microns
if lens == 60,
    if multiplier == 1.5,
    con = 0.104;
    else con = 0.152;
    end
elseif lens == 40,
    if multiplier == 1.5,
        con = 0.151;
    else con = 0.224;
    end
else con = 0.154;
end

% determine if we are interested in the absolute or relative motion of
% beads ( relative == ALL beads start at 0,0
if rel == 'r'
   rel = 'relative';
else rel = 'absolute';
end

% file loading loop
for z = 1:num_files,
    
    % debugging outputs
    filename = fu(z).name

    % call load video tracking to load the data
    d = load_video_tracking(filename, fr,'um',con,rel,'yes','table');

    % count the number of beads in a given tracking file
    n_beads = max(d(:,ID))+1;
    
    % create a data array to fill in with t and position infromation
    data = zeros(max(d(:,FRAME)+1)-min(d(:,FRAME)+1)+1,2*n_beads+1);
    
    size(data)
   
    % place position and time info into data matrix
    for j = 0:max(d(:,ID)),
        
        g = get_bead(d,j);    
        
        if j == 0,
            
            data(:,1) = g(:,TIME);
            data(:,2) = g(:,X);
            data(:,n_beads+2) = g(:,Y);
            
        else
            
            data(:,j+2) = g(:,X);
            data(:,j+2+n_beads) = g(:,Y);
            
        end
        
    end
        
    % save output
    filename_save_2 = strcat(filename,'_position.dat');
    save(filename_save_2, 'data', '-ASCII');

end

% pass data info back
d = data;