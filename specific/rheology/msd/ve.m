function v = ve(d, bead_radius, freq_type, plot_results)
% VE computes the viscoelastic moduli from mean-square displacement data 
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
% ve computes the viscoelastic moduli from mean-square displacement data.
% The output structure of ve contains four members: raw (contains data for 
% each individual tracker/bead), mean (contains means across trackers/beads), and 
% error (contains standard error (stdev/sqrt(Ntrackers) about the mean value, and Ntrackers (the
% number of trackers/beads in the dataset.
%
%  [v] = ve(d, bead_radius, freq_type, plot_results);  
%   
%  where "d" is the output structure of msd.
%        "bead_radius" is in [m].
%        "freq_type" is 'f' for [Hz] or 'w' for [rad/s], default is [Hz]
%        "plot_results" reports with a figure if 'y'. default is 'y'
%  
%  Notes:  
%  - This algorithm came from Mason 2000 Rheol Acta paper.
%  

if (nargin < 3) || isempty(freq_type)
    freq_type = 'f';   
end

if (nargin < 2) || isempty(bead_radius)
    bead_radius = 0.5e-6; 
end

if (nargin < 1) || isempty(d) || isempty(d.tau) || sum(isnan(d.tau(:))) >= length(d.tau(:))-1
    logentry('Error: no input data found.  Exiting now.'); 

    v.f = [];
    v.w = [];
    v.tau = [];
    v.msd = [];
    v.alpha = [];
    v.gamma = [];
    v.gstar = [];
    v.gp = [];
    v.gpp = [];
    v.nstar = [];
    v.np = [];
    v.npp = [];
    
    return;
end

msd = d.msd;
tau = d.tau;
Nestimates = d.Nestimates; % corresponds to the number of estimates for each bead at each tau

if isfield(d, 'Ntrackers')
    Ntrackers = d.Ntrackers; % corresponds to the number of trackers at each tau
else
    Ntrackers = sum( (d.Nestimates > 0), 2);
end


meantau = nanmean(tau,2);
% meanmsd = nanmean(msd,2);

% meantau = trimmean(tau, 15, 2);
% meanmsd = trimmean(msd, 15, 2);

logtau = log10(tau);
logmsd = log10(msd);

numbeads = size(logmsd,2);

% weighted mean for logmsd
weights = Nestimates ./ repmat(nansum(Nestimates,2), 1, size(Nestimates,2));

mean_logtau = nanmean(logtau');
mean_logmsd = nansum(weights .* logmsd, 2);

meanmsd = 10 .^ (mean_logmsd);

% computing error for logmsd
Vishmat = nansum(weights .* (repmat(mean_logmsd, 1, numbeads) - logmsd).^2, 2);
msderr =  sqrt(Vishmat ./ Ntrackers);


errhmsd = 10 .^ (mean_logmsd + msderr);
errlmsd = 10 .^ (mean_logmsd - msderr);


mygser  = gser(meantau, meanmsd, bead_radius);
maxgser = gser(meantau, errhmsd, bead_radius);
mingser = gser(meantau, errlmsd, bead_radius);

v = mygser;

v.error.f = abs(mygser.f - mingser.f);
v.error.w = abs(mygser.w - mingser.f);
v.error.tau = abs(mygser.tau - mingser.tau);
v.error.msd = abs(mygser.msd - mingser.msd);
v.error.alpha = abs(mygser.alpha - mingser.alpha);
v.error.gamma = abs(mygser.gamma - mingser.gamma);
v.error.gstar = abs(mygser.gstar - mingser.gstar);
v.error.gp = abs(mygser.gp - mingser.gp);
v.error.gpp = abs(mygser.gpp - mingser.gpp);
v.error.nstar = abs(mygser.nstar - mingser.nstar);
v.error.np = abs(mygser.np - mingser.np);
v.error.npp = abs(mygser.npp - mingser.npp);

v.raw = d;

v.Ntrackers = Ntrackers;

% plot output
if (nargin < 4) || isempty(plot_results) || strncmp(plot_results,'y',1)  
    fig1 = figure; fig2 = figure;
    plot_ve(v, freq_type, fig1, 'Gg');
    plot_ve(v, freq_type, fig2, 'Nn');
end

return;



% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 've: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    