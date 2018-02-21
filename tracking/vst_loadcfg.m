function outs = vst_loadcfg(cfgfiles)
% VST_LOADCFG Loads tracking configuration files for Video Spot Tracker
%
% CISMM function
% Tracking
%  
% Loads and aggregates tracking configurations from VST config files
% 
%  config = vst_loadcfg(cfgfiles)
%   
% 'cfgfiles' is a list of configuration files as strings
%

if nargin < 1 || isempty(cfgfiles)
    error('Must provide input file');
end

cfgfiles = dir(cfgfiles);

this = struct;
outs = struct;
for f = 1:length(cfgfiles)
    A = importdata(cfgfiles(f).name, ' ');
    
    if isempty(A)
        warning(['File ' cfgfiles(f).name ' not found. Continuing.']);
        continue;
    end

    for k = 1:length(A.textdata)
        this = setfield(this, A.textdata{k,2}, A.data(k));
    end
    
    % don't know why, but Matlab doesn't like fields assigned to a
    % structure array, so the first run through is just to define the
    % structure fields and set the values for the first file listed.
    if f == 1
        outs    = this;
    else
        outs(f) = this;
    end
end   

return;
