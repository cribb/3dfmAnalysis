function msd_out = msd_file_combine(filelist, data_labels, tau_target_in, fps_in, calibum_in)
% filelist is a cell array of filenames
% 'data_labels' is a cell array of data labels (can be used in boxplot)

if nargin < 1 || isempty(filelist)
    error('No files defined.');
end

filelist = filelist(:);
M = length(filelist);

if nargin < 2 || isempty(data_labels)
    data_labels = cell(M);
    for k = 1:M
        data_labels{k} = num2str(k);
    end
end

if nargin < 3 || isempty(tau_target_in)
    logentry('Assuming desired time scale for all files is 1 second');
    tau_target = 1;
    tau_target = repmat(tau_target_in, size(filelist));
elseif length(tau_target_in) == 1 && M ~= 1
    logentry('tau only defined for one file, assuming all files use this tau.');
    tau_target = repmat(tau_target_in, size(filelist));
elseif length(tau_target_in) ~= M
    error('Missing data, either from filelist or tau_target_in');
elseif length(tau_target_in) == M
    tau_target = tau_target_in;    
else
    error('Conditions for tau_target_in and filelist are not met.');
end

if nargin < 4 || isempty(fps_in)
    error('No fps defined');
elseif length(fps_in) == 1 && M ~= 1
    logentry('Only one fps defined, assuming all files use this fps.');
    fps = repmat(fps_in, size(filelist));
elseif length(fps_in) ~= M
    error('Missing data, either from filelist or fps_in');
elseif length(fps_in) == M
    fps = fps_in;
else
    error('Conditions for fps_in and filelist are not met.');
end

if nargin < 5 || isempty(calibum_in)
    error('No calibum_in defined');
elseif length(calibum_in) == 1 && M ~= 1
    logentry('Only one calibum_in defined, assuming all files use this calibum_in.');
    calibum = repmat(calibum_in, size(filelist));
elseif length(calibum_in) ~= M
    error('Missing data, either from filelist or calibum_in');
elseif length(calibum_in) == M
    calibum = calibum_in;
else
    error('Conditions for fps_in and filelist are not met.');
end

% fps = 30;
win = msd_gen_taus(47, 1);
% calibum = 0.157;
% tau_target = 1;

msd_out = struct;
Nmax = 0;

for k = 1:M
    
    thisfile = dir(filelist{k});
    
    if isempty(thisfile)
        error('File not found.');
    end
    
    vmsd = video_msd(thisfile.name, win, fps(k), calibum(k), 'n', 'n');
        
    vmsd_at_tau = msd_at_tau(vmsd, tau_target(k));
    
%     msd_out(k).data_labels = data_labels{k};
%     msd_out(k).msd = vmsd_at_tau.msd(:);
%     msd_out(k).Nestimates = vmsd_at_tau.Nestimates(:);
%     msd_out(k).tau = tau_target(k);   

      temp(k).msd = vmsd_at_tau.msd(:);
      temp(k).Nestimates = vmsd_at_tau.Nestimates(:);
      
      if length(vmsd_at_tau.msd(:)) > Nmax
          Nmax = length(vmsd_at_tau.msd(:)); % largest number of msd estimates in all of data
      end
    
end

msd_table = NaN(Nmax, M);
Nestimates_table = NaN(Nmax, M);

for k = 1:M    
    msd_table(1:length(temp(k).msd),k) = temp(k).msd;
    Nestimates_table(1:length(temp(k).Nestimates),k) = temp(k).Nestimates;
end

msd_out.data_labels = data_labels;
msd_out.msd         = msd_table;
msd_out.Nestimates  = Nestimates_table;
msd_out.tau         = tau_target;

return;
    
    