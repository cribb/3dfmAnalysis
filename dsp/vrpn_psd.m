function v = vrpn_psd(d, psdres, window)
% 3DFM function  
% DSP 
% last modified 05/07/04 - jcribb
%  
% This function adds the power spectral density (psd) structure
% to the 3dfm tracking structure.
%  
%  [d] = function_name(d, psdres, window);  
%   
%  where "d" is the 3dfm data structure (acquired from load_vrpn_tracking)
%		 "psdres" is the desired resolution between datapts in the PSD
%		 "window_type" is either 'blackman' or 'rectangle'
%  
%  Notes:  
%  - default psdres is the "best" resolution available to the routine
%    based on the data given (1/end_time).
%  - default window is 'rectangle'.
%
%  05/07/04 - created to replace now missing functionality of
%             load_vrpn_tracking; jcribb
%   
%  

% easier variables
t = d.beadpos.time;
xyz = [d.beadpos.x d.beadpos.y d.beadpos.z];

% construct sampling information (sampling frequency and period)
T = t(2) - t(1);
fs = 1/T;

% default window is a rectangle
if(nargin < 3 | isempty(window))
   	window = 'rectangle';
end

% if no desired psdres is passed as argument, then assume that
% the "best" resolution available should be used.  This is computed
% to be 1 / (last_sample_time - one_sample).
if(nargin < 2 | isempty(psdres))
   	psdres = 1 / (t(end)-T);
end

if(nargin < 1 | isempty(psdres))
  error('You must supply at least a 3dfm tracking structure.');
end

r = magnitude(xyz);

[psd,f] = mypsd([xyz r], fs, psdres, window);
        
d.psd.f = f;
d.psd.x = psd(:,1);
d.psd.y = psd(:,2);
d.psd.z = psd(:,3);
d.psd.r = psd(:,4);

v = d;

