function d = load_QPD_tracking(file);
% 3DFM function
% last modified 09/11/02
% 
% d = load_matlab_tracking(filename);
%
% where "filename" is the .mat filename (of QPD data)
%
% This function reads in a 3DFM dataset previously saved as a 
% 2-d matrix in a matlab workspace (converted from the log2mat
% utility) and converts it to the familiar 3dfm data structure.
%

	dd=load(file);        %load tracking data after it has been converted to a .mat file

	d.const.beadSize = 0.957;
	d.const.name = file;
	
	d.qpd.time  = dd.tracking.ComboTimeQuadsLevel(:,1);       % get time data
	d.qpd.q1    = dd.tracking.ComboTimeQuadsLevel(:,2);       % get stage x data
	d.qpd.q2    = dd.tracking.ComboTimeQuadsLevel(:,3);       % get stage y data
	d.qpd.q3    = dd.tracking.ComboTimeQuadsLevel(:,4);       % get stage z data
	d.qpd.q4    = dd.tracking.ComboTimeQuadsLevel(:,5);            % get data from individual 

																 % get data from laser at top of system 
	d.laser=dd.tracking.ComboTimeQuadsLevel(:,6);		     % (after being split out of the 98/2 
																 % beam splitter

	% set the QPD quadrants to easy q1, q2, q3, q4
	q1 = d.qpd.q1;
	q2 = d.qpd.q2;
	q3 = d.qpd.q3;
	q4 = d.qpd.q4;
	
	% compute the position of bead for  x (left - right) 
	% 									y (top - bottom)
	%									z sum of all quads
	d.pos.x = (q1+q3)-(q2+q4);
	d.pos.y = (q1+q2)-(q3+q4);
	d.pos.z = q1 + q2 + q3 + q4;													 



	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% get the power spectral density (only at constant sampling freq)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	x = d.pos.x;
	y = d.pos.y;
	z = d.pos.z;
	
		res = 0.3; %Hz, resolution of the psd
		[psd f] = mypsd([x y z], 20000, res);
		d.psd.f = f;
		d.psd.x = psd(:, 1);
		d.psd.y = psd(:, 2);
		d.psd.z = psd(:, 3);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% output the calculated data structure
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	v=d;

	