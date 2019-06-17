function m = ba_process_expt(filepath)

rootdir = pwd;

cd(filepath);

calibum = 0.346;
visc_Pas = 0.010;
bead_diameter_um = 24;

filelist = dir('*.vrpn.evt.mat');
m = cell(length(filelist));
for k = 1:length(filelist)
    m{k} = get_evt_linfits(filelist(k).name, calibum, visc_Pas, bead_diameter_um);
end

m = vertcat(m{:});
m = sortrows(m, 'Force', 'ascend');
m.PercentLeft = 100*[length(m.Force):-1:1]'./length(m.Force);

[g, grpnames] = findgroups(m.Filename);

% figure;
% gscatter(m.Force, m.PercentLeft, g);
% set(gca, 'XScale', 'log');
% xlabel('Force, F [N]');
% 
% figure;
% semilogx(m.Force, m.PercentLeft, '.');
% xlabel('Force, F [N]');

cd(rootdir);
