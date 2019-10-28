function outs = ba_process_expt(filepath)
% This function begins the process of analyzing the output of the bead
% adhesion experiment where the bead detaches from the surface and moves
% through z while being tracked by vst. The z-velocity is then used to back
% out the detachment force

rootdir = pwd;

cd(filepath);

search_radius_low = 10;
search_radius_high = 26;

evtfilelist = dir('*.vrpn.evt.mat');

for k = 1:length(evtfilelist)

   basename = strrep(evtfilelist(k).name, '.vrpn.evt.mat', '');
   
   % Load data from metadata file. Ultimately, use this as indexing file 
   % when combining data for an entire experiment
   metadata = load([basename '.meta.mat']);
   
   Fid = metadata.File.Fid;
   visc_Pas = metadata.Medium.Viscosity;
   calibum = metadata.Scope.Calibum;   
   bead_diameter_um = metadata.Bead.Diameter;   
   Ztable = metadata.Results.TimeHeightVidStatsTable;
   Ztable.Time = (Ztable.Time - Ztable.Time(1));
   firstframe = metadata.Results.FirstFrame;
   lastframe = metadata.Results.LastFrame;
   
  
   FileTable{k} = shorten_metadata(metadata);
   
   % Need to use original VST tracking file to find how many beads existed 
   % on the first frame.
   origtracks = load_video_tracking([basename '.csv']);
   FileTable{k}.FirstCount = length(unique(origtracks.id(origtracks.frame == 1)));
   
   BeadInfoTable{k} = ba_discoverbeads(firstframe, lastframe, search_radius_low, search_radius_high, Fid);   
      
   ForceTable{k} = ba_get_linefits(evtfilelist(k).name, calibum, visc_Pas, bead_diameter_um, Fid);
   ForceTable{k}.ZmotorPos = interp1(Ztable.Time, Ztable.ZHeight, ForceTable{k}.Mean_time);
end

ForceTable = vertcat(ForceTable{:});
% ForceTable.Filename = [];

FileTable = vertcat(FileTable{:});
BeadInfoTable = vertcat(BeadInfoTable{:});

[g, grpT] = findgroups(FileTable(:,{'BeadChemistry', 'Media'}));
NStartingBeads(:,1) = splitapply(@sum, FileTable.FirstCount, g);
NStartingBeadsT = [grpT, table(NStartingBeads)];

T = join(ForceTable, FileTable(:,{'Fid', 'BeadChemistry', 'Media'}));
T = join(T, NStartingBeadsT);

[g, grpT] = findgroups(T(:,{'BeadChemistry', 'Media'}));

fracleft = splitapply(@(x1,x2){sa_fracleft(x1,x2)},T.Force,T.NStartingBeads,g);
fracleft = cell2mat(fracleft);
ForceTable.FractionLeft = fracleft;
T.FractionLeft = fracleft;


cd(rootdir);
 
outs.FileTable = FileTable;
outs.ForceTable = ForceTable;
outs.BeadInfoTable = BeadInfoTable;

end


function sm = shorten_metadata(metadata)
    sm.Fid = metadata.File.Fid;
    sm.FullFilename = string(fullfile(metadata.File.Binpath, metadata.File.Binfile));
    sm.StartTime = metadata.Results.TimeHeightVidStatsTable.Time(1);
    sm.MeanFps  = 1 ./ mean(diff(metadata.Results.TimeHeightVidStatsTable.Time*86400));
    sm.ExposureTime = metadata.Video.ExposureTime;
    sm.Binfile = string(metadata.File.Binfile);
    sm.SampleName = string(metadata.File.SampleName);
    sm.BeadChemistry = string(metadata.Bead.SurfaceChemistry);
    sm.SubstrateChemistry = string(metadata.Substrate.SurfaceChemistry);
    sm.Media = string(metadata.Medium.Name);
    sm.MediumViscosity = metadata.Medium.Viscosity;
    sm.Calibum = metadata.Scope.Calibum;    
    
    if isfield(metadata.Substrate, 'LotNumber')
        sm.SubstrateLotNumber = string(metadata.Substrate.LotNumber);
    end
    
    sm = struct2table(sm);
    
    sm.BeadChemistry = categorical(sm.BeadChemistry);
    sm.SubstrateChemistry = categorical(sm.SubstrateChemistry);
    sm.Media = categorical(sm.Media);
end

function outs = sa_fracleft(force, startCount)

    force = force(:);
    Nforce = length(force);   
    
    [~,Fidx] = sort(force, 'ascend');
    
    FRank(Fidx,1) = [1:Nforce];
    
    outs = 1-(FRank ./ startCount);

end




