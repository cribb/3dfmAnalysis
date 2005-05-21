function v = filter_out_repeats_in_vrpn(filemask)
% 3DFM function  
% Tracking 
% last modified 05/17/05 
%  
% This function strips out repeated entries in a vrpn.mat file  
%  
%  v = filter_out_repeats_in_vrpn(filemask);  
%   
%  where "filemask" is the vrpn.mat file(s) containing repeated log entries
%  (wildcards ok)
%  
%  05/17/05 - created; jcribb.
%  

files = dir(filemask);
% for each file
for f = 1: length(files)
    
    fname = files(f).name;
    data = load(fname, '-mat');
    data = data.tracking.spot3DSecUsecIndexFramenumXYZRPY;
    copyfile(fname, [fname '.bak']);
    
	% for each bead
	for k = 0 : max(data(:,3))
        
        kidx = find(data(:,3) == k);
        bead_data = data(kidx,:);
        
        % for each frame
        for m = 0 : max(bead_data(:,4))
            
            midx = find(bead_data(:,4) == m);
            
            if length(midx) > 1
                frame_data = bead_data(max(midx), :);
            else
                frame_data = bead_data(midx,:);
            end
     
            if ~exist('new_data')
                new_data = frame_data;
            else
                new_data = [new_data ; frame_data];
            end        
        end
	end
    
    tracking.spot3DSecUsecIndexFramenumXYZRPY = new_data;
    save(fname, 'tracking');
    
    clear new_data;
end

v = 0;  % everything works out fine

return;

