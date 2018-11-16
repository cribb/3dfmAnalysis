function v = vst_autotrack_stacks(exptpath, filename, cfgfiles)

if nargin < 3 || isempty(cfgfiles)
    cfgfiles.find = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\optimize_z_find.cfg';
    cfgfiles.track = 'D:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\optimize_z_track.cfg';
end

if nargin < 2 || isempty(filename)
    error('No file to track.');
end

if nargin < 1 || isempty(exptpath)
    error('No folder provided.');
end

% Check for the expt directory
tmp = dir(exptpath);

if ~isempty(tmp)
    exptpath = tmp.folder;
else
    error('Folder not found.');    
end

startpath = pwd;

cd(exptpath);
    
[~,findcfg,fext] = fileparts(cfgfiles.find);
[~,trackcfg,text] = fileparts(cfgfiles.track);

findcfg = [findcfg, fext];
trackcfg = [trackcfg, text];

vc = vst_config_init;    

configFind = [exptpath filesep findcfg];
configTrack = [exptpath filesep trackcfg];

copyfile(cfgfiles.find, configFind );
copyfile(cfgfiles.track, configTrack );

filelist = dir(['**/' filename]);

    for k = 1:length(filelist)
        
        fldrname = filelist(k).folder;
        
        cd(fldrname);
        
        firstframe = fullfile(filelist(k).folder, filelist(k).name);
        findframefilename =  fullfile(filelist(k).folder, 'findframe.pgm');
        
        % copy first frame into a new filename so initialize bead positions
        [success,msg,msgid] = copyfile(filelist(k).name, findframefilename);
        
        if ~success
            error('File not copied.');
        end
        
        logfile = filelist(k).folder;
        findlog = [logfile '_tmp'];
        
        
        vst_check_config(vc);
        vst_run_from_matlab(findframefilename, findlog, configFind, vc);
        
        
        vc.continue_from = [findlog '.csv'];
        vst_run_from_matlab(firstframe, logfile, configTrack, vc);
        
        delete(findframefilename);
        delete([findlog '.vrpn']);
        delete([findlog '.csv']);
        delete(findcfg);
        delete(trackcfg);
    end    

    cd(startpath);
        
    v = 0;
    
end
