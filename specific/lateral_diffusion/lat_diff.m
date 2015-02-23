function outs = lat_diff(filelist, frame_rate, calib_um, init_conc, conc_unit, title_string)
% analyze lateral diffusion experiment

if ~exist('filelist') || isempty(filelist)
    filelist = dir('*.pgm');
    logentry('No filenames defined. Selected all PGM files in the working directory');
end

if ~exist('frame_rate') || isempty(frame_rate)
    frame_rate = 5;
    logentry('WARNING: No frame rate defined. Assuming 5 fps.');   
end

if ~exist('calib_um') || isempty(calib_um)
    calib_um = 0.361; % [um/pixel] (consistent with Monoptes 20X obj + 39N0 varioptic lens
    logentry('WARNING: No XY calibration defined. Assuming Monotpes 20X+39N0 condition');
end

if ~exist('conc_unit') || isempty(conc_unit)
    conc_unit = 'AU';
end

if ~exist('init_conc') || isempty(init_conc)
    init_conc = 100;
    conc_unit = '%';
    logentry('WARNING: No concentration defined. Normalizing concentration to one.');
end

if ~exist('title_string')
    title_string = '';
end

% start timing-- loading all these images can take awhile.
tic;


% collect the data from the file list
numfiles = length(filelist);
for k = 1:numfiles
    
    im = double(imread(filelist(k).name));
    my_row = im(242,:);
    mean_row = mean(im,1);
    
    sum_im(k,:) = sum(im(:));
    my_rows(k,:) = my_row;
    my_means(k,:) = mean_row;
        
end

% define the time scales
t = 0:1/frame_rate:(numfiles-1)/frame_rate;
t = t(:);

% define the length scales
x = [0 : calib_um : calib_um * (size(im,2)-1)];

% find the right places in x for diff distance determination
x25 = min(x) + (mean(x) / 2);
x75 = max(x) - (mean(x) / 2);

[~,idx25] = min(abs(x-x25));
[~,idx75] = min(abs(x-x75));


% normalize the summed intensities
sum_im = sum_im ./ max(sum_im(:));

% handle fitting for photobleaching and normalize the data accordingly.
% This is not a mature way to deal with the possibility that the data do
% not fit the double exponential as the literature suggests. Instead it
% just fits it to a line.
try
    my_fit = fit(t, sum_im, fittype('exp2'));
catch
    my_fit = fit(t, sum_im, fittype('Poly1'));  % simple line fit
end

% compute the normalization factors from the fit and normalize the data for
% photobleaching
norm_factors = 1./my_fit(t);
norm_factors = repmat(norm_factors, 1, size(im,2));
norm_means = (my_means .* norm_factors)';

% now scale the data to have '1' as the maximum value
norm_means = norm_means ./ max(norm_means(:));

% compute the normalization factors that scale the luminance values for concentration
conc_means = init_conc .* norm_means;

% pull out some selection of rows to plot as a seris of xy scatter plots
num_selected_sums = 10;
selection = [round(1:numfiles/num_selected_sums:numfiles) numfiles];
selected_conc_means = conc_means(:,selection);

for k = 1:length(selection)
%     legend_entries{k} = ['t= ' num2str(t(selection(k))) ' s'];
    legend_entries{k} = num2str(t(selection(k)));
end

figure;
imagesc(t, x, conc_means); 
title([title_string ', conc profile in [' conc_unit ']']);
xlabel('time, t [s]');
ylabel('x [\mum]');
colormap(hot(256));
colorbar;
pretty_plot;

figure;
plot(x, selected_conc_means);
title(title_string);
xlabel('x [\mum]');
ylabel(['concentration [' conc_unit ']']);
legend(legend_entries);
pretty_plot;

figure; 
plot(t, sum_im, 'b', t, my_fit(t), 'r');
title([title_string ', Intensity Profile']);
xlabel('time, t [s]');
ylabel('norm. sum(intensity)');
legend('data', 'fit');
pretty_plot;

figure;
plot(t, [conc_means(idx25,:)' conc_means(idx75,:)']);
xlabel('time, [s]');
ylabel(['conc. [' conc_unit ']']);
legend('x(0.25)','x(0.75)');
pretty_plot;
    
% handle the output structure
outs.t = t;
outs.x = x;
outs.intensity_sums = sum_im;
outs.bleaching_fit = my_fit;
outs.norm_factors = norm_factors;
outs.raw_means = my_means;
outs.diff_profile = conc_means;
outs.frame_rate = frame_rate;
outs.duration = round(t(end));
outs.calib_um = calib_um;
outs.init_conc = init_conc;
outs.conc_unit = conc_unit;
outs.title = title_string;

% stop timing & report how long it took
toc;

return;



