function v = video_psd(d, psdres, window)
% 3DFM function  
% video/DSP
% last modified 04/03/06 - jcribb
%  
% This function adds the power spectral density (psd) structure
% to the 3dfm video tracking structure.  This means that the input data
% must be in the structure format.
%  
%  [d] = video_psd(d, psdres, window);  
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

% default window is a rectangle
if(nargin < 3 | isempty(window))
   	window = 'rectangle';
end

if(nargin < 1 | isempty(d))
  error('You must supply at least a 3dfm tracking structure.');
end

video_tracking_constants;

for k = 0:get_beadmax(d)-1;

    bead = get_bead(d,k);

    % easier variables
    t = bead.t - bead.t(1);
    xyz = [bead.x bead.y bead.z];

    % construct sampling information (sampling frequency and period)
    T = t(2) - t(1);
    fs = 1/T;

    % if no desired psdres is passed as argument, then assume that
    % the "best" resolution available should be used.  This is computed
    % to be 1 / (last_sample_time - one_sample).
    if(nargin < 2 | isempty(psdres))
        psdres = 1 / (t(end)-T);
    end
    r = magnitude(xyz);

    [psd,f] = mypsd([xyz r], fs, psdres, window);

    d.psd.f(:,k+1) = f;
    d.psd.x(:,k+1) = psd(:,1);
    d.psd.y(:,k+1) = psd(:,2);
    d.psd.z(:,k+1) = psd(:,3);
    d.psd.r(:,k+1) = psd(:,4);

end

v = d;

