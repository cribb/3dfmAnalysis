function v = thd(peak, freqs, data)
% THD Computes total harmonic distortion
%
% 3DFM function  
% Utilities 
% last modified 11/14/08 (Kris Ford) 
%  
% This function computes Total Harmonic Distortion.
%  
%  v = thd(peak, freqs, data);  
%   
%  where:  peak is the "zeroth" peak (initial peak)
%          freqs is a vector of frequencies 
%		   data is a vector of data
  
tolerance = 0.01;

len = floor( max(freqs) / peak );

m = [1:len] * peak;


for k = 1:length(m)
    f = find(freqs >= (1-tolerance) * m(k) & ...
             freqs <= (1+tolerance) * m(k));
    b(k) = sum(data(f));
end

v = sqrt(sum(b(2:end).^2)) / b(1);




