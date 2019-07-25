function outs = ba_process_expt(filepath)

rootdir = pwd;

cd(filepath);

calibum = 0.346;
% visc_Pas = 0.010;
bead_diameter_um = 24;

search_radius_low = 10;
search_radius_high = 26;

evtfilelist = dir('*.vrpn.evt.mat');

<<<<<<< HEAD
ForceTable = cell(length(evtfilelist));
BeadInfoTable = cell(length(evtfilelist));
=======
m = cell(length(evtfilelist),1);
b = cell(length(evtfilelist),1);
>>>>>>> 3bb89ce0d4a85f1f541dd8878c2ba5606af0fe74

for k = 1:length(evtfilelist)

   basename = strrep(evtfilelist(k).name, '.vrpn.evt.mat', '');
   
   % load data from metadata files (ultimately use this as indexing file)
   metadata = load([basename '.meta.mat']);
   
   Fid = metadata.File.Fid;
   visc_Pas = metadata.Medium.Viscosity;
   firstframe = imread([basename '.00001.pgm']);
   lastframe = imread([basename '.07625.pgm']);
   
  
   FileTable{k} = shorten_metadata(metadata);
   
   % Need to use original VST tracking file to find how many beads existed 
   % on the first frame.
   origtracks = load_video_tracking([basename '.csv']);
   FileTable{k}.FirstCount = length(unique(origtracks.id(origtracks.frame == 1)));
   
   BeadInfoTable{k} = ba_discoverbeads(firstframe, lastframe, search_radius_low, search_radius_high, Fid);
   
      
   ForceTable{k} = get_evt_linfits(evtfilelist(k).name, calibum, visc_Pas, bead_diameter_um, Fid);
end

ForceTable = vertcat(ForceTable{:});
ForceTable.Filename = [];

FileTable = vertcat(FileTable{:});
BeadInfoTable = vertcat(BeadInfoTable{:});

[g, grpT] = findgroups(FileTable(:,{'BeadChemistry', 'Media'}));
NStartingBeads(:,1) = splitapply(@sum, FileTable.FirstCount, g);
NStartingBeadsT = [grpT, table(NStartingBeads)];

T = join(ForceTable, FileTable(:,{'Fid', 'BeadChemistry', 'Media'}));
T = join(T, NStartingBeadsT);

[g, grpT] = findgroups(T(:,{'BeadChemistry', 'Media'}));

% T = splitapply(@(x1,x2)sortrows(x1,x2,'descending'), T, T.Force, g);

fracleft = splitapply(@(x1,x2){sa_fracleft(x1,x2)},T.Force,T.NStartingBeads,g);
fracleft = cell2mat(fracleft);
ForceTable.FractionLeft = fracleft;
T.FractionLeft = fracleft;

figure;
gscatter(ForceTable.Force*1e9, ForceTable.FractionLeft*100, g);
set(gca, 'XScale', 'log');
xlabel('Force, F [nN]');
ylabel('Percent Left [%]');

% figure;
% semilogx(ForceTable.Force*1e9, ForceTable.FractionLeft*100, '.');
% xlabel('Force, F [N]');
% ylabel('Percent Left [%]');
% cd(rootdir);

outs.FileTable = FileTable;
outs.ForceTable = ForceTable;
outs.BeadInfoTable = BeadInfoTable;

end


function sm = shorten_metadata(metadata)
    sm.Fid = metadata.File.Fid;
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