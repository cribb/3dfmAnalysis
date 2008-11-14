function v = erase_negatives_in_vrpn(filemask)
% ERASE_NEGATIVES_IN_VRPN Removes negative frame numbers in a vrpn.mat file.
%
% 3DFM function  
% Tracking 
% last modified 2008.11.14 (jcribb)
%  
% This function strips out negative frame numbers in a vrpn.mat file  
%  
%  v = erase_negatives_in_vrpn(filemask);  
%   
%  where "filemask" is the vrpn.mat file(s) containing repeated log entries
%  (wildcards ok)
%  
%  05/18/05 - created; sorell massenburg.
%               modeled on filter_out_repeats_in_vrpn

%  05/23/05 - modified; sorell massenburg

files = dir(filemask);

for f = 1: length(files);  %for each file

        fname = files(f).name;
        data =  load(fname, '-mat');
        data = data.tracking.spot3DSecUsecIndexFramenumXYZRPY;
        copyfile(fname, [fname '-.bak']);
        
% for each bead
	for k = 0 : max(data(:,3))
        
        kidx = find(data(:,3) == k);
        bead_data = data(kidx,:);
                    
           % for each frame
        for m = 0 : max(bead_data(:,4))
            frameno = find(bead_data(:,4) == m);
            
            if m < 0
                bead_data(frameno, :) = [];
            else
                frame_data = bead_data(frameno,:);
            end
            
            if ~exist('new_data')
               new_data=frame_data;
           else
               new_data = [new_data ; frame_data];
           end
           clear frame_data;    %could mess things up
       end
   end
   
    tracking.spot3DSecUsecIndexFramenumXYZRPY = new_data;
    save(fname, 'tracking');
    
    clear new_data;
end

v = 0;

return;