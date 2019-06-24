function outs = ba_process_expt(filepath)

rootdir = pwd;

cd(filepath);

calibum = 0.346;
visc_Pas = 0.010;
bead_diameter_um = 24;

search_radius_low = 10;
search_radius_high = 26;

evtfilelist = dir('*.vrpn.evt.mat');

m = cell(length(evtfilelist));
b = cell(length(evtfilelist));

for k = 1:length(evtfilelist)

   basename = strrep(evtfilelist(k).name, '.vrpn.evt.mat', '');
   
   % load data from metadata files (ultimately use this as indexing file)
   metadata = load([basename '.meta.mat']);
   
   Fid = metadata.Video.Fid;
   firstframe = imread([basename '.00001.pgm']);
   lastframe = imread([basename '.07625.pgm']);
   
   % Need to find where the beads began and determine whether they left
   
   a{k} = shorten_metadata(metadata);
   
   b{k} = ba_discoverbeads(firstframe, lastframe, search_radius_low, search_radius_high, Fid);
   
   % 
   m{k} = get_evt_linfits(evtfilelist(k).name, calibum, visc_Pas, bead_diameter_um, Fid);
end

m = vertcat(m{:});
m = sortrows(m, 'Force', 'ascend');
m.PercentLeft = 100*[length(m.Force):-1:1]'./length(m.Force);
m.Filename = [];

a = vertcat(a{:});
b = vertcat(b{:});

outs.FileTable = a;
outs.ForceTable = m;
outs.BeadInfoTable = b;

% [g, grpnames] = findgroups(m.Filename);
% 
% figure;
% gscatter(m.Force, m.PercentLeft, g);
% set(gca, 'XScale', 'log');
% xlabel('Force, F [N]');
% 
% figure;
% semilogx(m.Force, m.PercentLeft, '.');
% xlabel('Force, F [N]');

cd(rootdir);

end


function outs = shorten_metadata(metadata)
    outs.Fid = metadata.Video.Fid;
    outs.StartTime = metadata.Video.TimeHeightTable.time(1);
    outs.MeanFps  = 1 ./ mean(diff(metadata.Video.TimeHeightTable.time));
    outs.ExposureTime = metadata.Camera.ExposureTimeSet;
    outs.Binfile = string(metadata.Video.Binfile);
    outs.SampleName = string(metadata.Video.SampleName);
    outs.BeadChemistry = string(metadata.Video.BeadChemistry);
    outs.SubstrateChemistry = string(metadata.Video.SubstrateChemistry);
    outs.Media = string(metadata.Video.Media);
    outs.Calibum = metadata.Video.Calibum;
    
    outs = struct2table(outs);
end