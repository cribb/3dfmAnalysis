function v = diffusion_coefficient(data, sampling_rate)
% 3DFM function  
% Rheology 
% last modified 05/07/04 
%  
% This function computes a window-size dependent diffusion coefficient 
% from a vector of displacements.
%  
% v = diffusion_coefficient(data, sampling_rate);
%   
%  where "data" is a vector of displacements
%        "sampling_rate" is the sampling rate of the data in [Hz]
%  
%  Notes:  
%   
%   
%  05/07/03 - created; jcribb
%  07/28/03 - added limited documentation; jcribb
%  05/07/04 - expanded documentation; jcribb
%     
%  


  % getting tau_zero
	dt0 = 1/sampling_rate;
	
	[rows cols] = size(data);
	
  % want a maximum window size that is one-half the length of the dataset.
	window_max = floor(rows/2);

	for window_size = 1:window_max
        dt(window_size) = window_size * dt0;
        slider_max = rows - window_size;
        for slider = 1 : slider_max
            x(slider) = (data(slider + window_size) - data(slider)) ^ 2;
        end
        mean_squared_x(window_size) = sum(x) / slider_max;
	end
	
	diff_coeff = mean_squared_x ./ (2*dt);

    p = polyfit(2*dt, mean_squared_x, 1);
    reg = polyval(p, 2*dt);
    
    figure(1);
    plot(2*dt, [mean_squared_x ; reg]);
    legend('data', 'linear fit');
    xlabel('2*dt');
    ylabel('mean_squared_x');
    
    
    
	v.dt = dt;
  v.mean_squared_x = mean_squared_x;
	v.diff_coeff = diff_coeff;
