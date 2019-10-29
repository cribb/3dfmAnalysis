function vst_check_config(ins)

if isfield(ins, 'VSTdir')
    if ~exist(ins.VSTdir, 'file')
        error('Video Spot Tracker directory is not found at the prescribed location. Is VST installed?');
    end
else
    error('VSTdir is not defined in input structure.');
end

if isfield(ins, 'VSTcuda')
    if ~exist(join([ins.VSTdir,filesep,ins.VSTcuda],''), 'file')
        warning('CUDA executable not found. Check configuration.');
    end
else
    warning('No CUDA executable defined. Cannot use CUDA hardware');
end

if isfield(ins, 'VSTexe')
    if ~exist(join([ins.VSTdir,filesep,ins.VSTexe],''), 'file')
        error('Video Spot Tracker executable not found. Check your configuration.');
    end
else
    error('No Video Spot Tracker executable defined. Add VSTexe field to configuration.');
end

if isfield(ins, 'tclpath')
    if ~exist(ins.tclpath, 'file')
        error('Video Spot Tracker TCL directory not found. Check your VST installation.');
    end
else
    error('Video Spot Tracker TCL path not defined. Add tclpath field to configuration.');
end

if isfield(ins, 'tkpath')
    if ~exist(ins.tkpath, 'file')
        error('Video Spot Tracker TK directory not found. Check your VST installation.');
    end
else
    error('Video Spot Tracker TK path not defined. Add tkpath field to configuration.');
end

if isfield(ins, 'command')
    if ~exist(ins.command, 'file')
        error('Video Spot Tracker command call file not found. Check your VST installation.');
    end
else
    error('Video Spot Tracker command call is not defined. Add command field to configuration.');
end