function v = diffusion_coefficient(data, sampling_rate, step_size)
    
dt0 = 1/sampling_rate;

[r c] = size(data);

window_max = floor(r/2);

for window_size = 1:step_size:window_max

    dt(window_size) = window_size * dt0;
    
    slider_max = length(data) - window_size;
    
    x = (data(window_size+1 : end, :) - data(1 : end - window_size, :)) .^ 2;

    mean_squared_x(window_size,:) = 1/slider_max * sum(x,1);

end
dtm = repmat(dt,c,1)';
diff_coeff = mean_squared_x ./ (2*dtm);

v.dt         = dt';
v.diff_coeff = diff_coeff;
