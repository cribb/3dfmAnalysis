function v = laser_spring_constant(d, plots)
% LASER_SPRING_CONSTANT computes spring constant (N/m) for 3DFM tracking laser in x, y, and z
%
% 3DFM function
% last modified on 11/14/08 (krisford)
%
% This function computes the spring constant in N/m for the
% 3DFM tracking laser in x, y, & z from collected stage data.
% The output is a 3 element array: [x_k y_k z_k]
% 
% get_laser_k(d, plots)
%
% where d is the standard 3DFM data structure.
% and plots is a string denoting which plots are desired.
%
% 'h' histogram of displacement
% 'e' energy
% 'd' displacement vs. time
%

if (nargin < 2)
    plots = '';
end

boltzmann_const = 1.380658e-5;    % (kg*nm^2)/(s^2*K)
temperature     = 298;            % K (equal to 25oC)
dim_label=['X' 'Y' 'Z'];
res = min(diff(d.stage.time));

count=1;
for stage_position=[d.stage.x d.stage.y d.stage.z]
	% normalize displacements (subtract means)
	x = stage_position - mean(stage_position);	

	% generate a histogram
	displacement=min(x):res:max(x);
	freq_counts=hist(x,displacement); 

	%get rid of zeros (and anything after their indexed position)
	zeros_index=find(freq_counts < 1);          
	length_freq_counts=length(freq_counts);
	index_to_subtract=length_freq_counts-(min(abs(1/2*length_freq_counts-zeros_index)))*2;
	h=freq_counts(index_to_subtract:length_freq_counts-index_to_subtract);
	dist_cut=displacement(index_to_subtract:length_freq_counts-index_to_subtract);
	energy=-boltzmann_const*temperature*log(h);            %[10^-21 J] energy=-kb*T*log(freq_counts); %=> can't take log of zero
	p=polyfit(dist_cut,energy,2); 
	xi=linspace(-0.5*length(h),0.5*length(h),90); po=polyval(p,xi);


	k_measured(count)=p(1)*2;              %[N/m]	
	
	[rows columns]=size(plots);
	if columns<1
		% do nothing... get the hell out
	else
		g=figure;
		sp=1;
	end
	
	if(findstr('h',plots))
	    figure(g); 
		subplot(1,columns,sp);
		bar(displacement,freq_counts);
		title([dim_label(count) ' displacement distribution']);
		xlabel('displacement (nm)');
		ylabel('frequency (counts)');
		sp=sp+1;
	end

	if(findstr('e',plots))
		figure(g); 
		subplot(1,columns,sp);
		plot(dist_cut,energy,'o',xi,po,':');
		title('Energy of laser trap');
		xlabel('displacement (nm)');
		ylabel('energy [10^-^2^1 J]');
		sp=sp+1;
	end

	if(findstr('d',plots))
		figure(g);
		subplot(1,columns,sp);
		plot(d.stage.time,x);
		title(['Normalized Displacement in ' dim_label(count) ' vs. time']);
		xlabel('time (seconds)');
		ylabel('bead displacement (nm)');
		sp=sp+1;
	end

	count = count + 1;
end	

fprintf('\n[x y z] spring constants in [N/m]\n');
v =	k_measured;
