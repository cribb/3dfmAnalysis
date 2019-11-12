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

if isempty(cfgfiles)
        error(['File ' cfgfiles(f).name ' not found. Continuing.']);
        outs = [];
        return
end

this = struct;
outs = struct;

for f = 1:length(cfgfiles)
    
    fid = fopen(cfgfiles(f).name);
    
    A = textscan(fid, 'set %s %s');        

    fnames = A{:,1};
    values = A{:,2};
    
    values = cellfun(@str2num, values, 'UniformOutput', false);
    
    for k = 1:length(fnames)
        this = setfield(this, fnames{k,1}, values{k,1});
    end
    
    % don't know why, but Matlab doesn't like fields assigned to a
    % structure array, so the first run through is just to define the
    % structure fields and set the values for the first file listed.
    if f == 1
        outs    = this;
    else
        outs(f) = this;
    end
    
    fclose(fid);
end   

return
