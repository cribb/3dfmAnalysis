function m=mat2txt(file);
% 3DFM function  
% Utilities 
% last modified 05/07/2004
%  
% This function takes a 3dfm data structure (.mat file) and converts
% the bead position in (x,y,z) to a three-column text file.
%  
%  [m] = mat2txt(file);
%   
%  where "file" is a filename containing the 3dfm data structure.
%  
%  06/21/2002 - created; jcribb
%  05/07/2004 - updated to new data structure; jcribb


	d = load_vrpn_tracking(file);
	d = [d.beadpos.x d.beadpos.y d.beadpos.z];
  
  newfile = [file(1:end-4) '.txt'];
	
  save(newfile,'d', '-ascii', '-double', '-tabs');
	
  m=d;

