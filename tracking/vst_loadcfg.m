function outs = vst_loadcfg(cfgfile)

if nargin < 1 || isempty(cfgfile)
    error('Must provide input file');
end

cfgfile = dir(cfgfile);

this = struct;
outs = struct;
for f = 1:length(cfgfile)
    A = importdata(cfgfile(f).name, ' ');
    
    if isempty(A)
        warning(['File ' cfgfile(f).name ' not found. Continuing.']);
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
