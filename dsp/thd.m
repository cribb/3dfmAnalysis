function v = thd(peak, freqs, data)
% 3DFM function  
% Utilities 
% last modified 08/11/2003 
%  
% This function computes Total Harmonic Distortion.
%  
%  v = thd(peak, freqs, data);  
%   
%  where:  peak is the "zeroth" peak (initial peak)
%          freqs is a vector of frequencies 
%		   data is a vector of data
%  
%  Notes:  
%   
%   
%  08/11/03 - created.  
%   
%  
tolerance = 0.01;

len = floor( max(freqs) / peak );

m = [1:len] * peak;


for k = 1:length(m)
    f = find(freqs >= (1-tolerance) * m(k) & ...
             freqs <= (1+tolerance) * m(k));
    b(k) = sum(data(f));
end

v = sqrt(sum(b(2:end).^2)) / b(1);




