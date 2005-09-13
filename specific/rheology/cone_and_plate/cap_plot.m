function cap_plot(d, plottype)
% 3DFM function  
% Rheology::cone_and_plate
% last modified 05/09/2005
%  
% Plots exported rheological data from Bohlin Gemini cone-and-plate 
% rheometer.
%  
%  [outputs] = cap_plot(data, plottype);  
%   
%  where "data" is structure containing rheology data
%        "plottype" is one of the following strings:
%                   'creep' -- 
%                   'viscometry' -- 
%                   'viscometry:yield' -- 
%                   'sweep:amp' --
%                   'sweep:amp:all' -- 
%                   'sweep:freq:angle' --
%  
%  NOTES: If both input arguments are not defined, then the result is default
%  behavior, i.e. construct default plots for any XLS file in the current
%  directory.  The convention for the filenames requires the strings
%  'creep', 'viscometry', 'amp', or 'freq' as a means to direct which
%  plots and which conversions (.XLS -> .MAT) to make.
%   
%  03/31/05 - created; jcribb.
%  05/09/05 - added documentation.  added right-facing triangle to 2nd
%  point in plots (for determining which side of the data is the UP
%  direction in UP-then-DOWN rheology scans.
%  


if nargin < 2
    files = dir('*.xls');

	for k = 1 : length(files)
        
        file = files(k).name;
        lfile = lower(file);
        
        if strfind(lfile, 'creep')
            plottype = 'creep';
            d = cap_creep(lfile);
        elseif strfind(lfile, 'viscometry') & ~strfind(lfile, 'yield')
            plottype = 'viscometry';            
            d = cap_viscometry(lfile);
        elseif strfind(lfile, 'viscometry') & strfind(lfile, 'yield')
            plottype = 'viscometry:yield';
            d = cap_yield(lfile);
        elseif strfind(lfile, 'amp')
            plottype = 'sweep:amp'; 
            d = cap_sweep(lfile);
        elseif strfind(lfile, 'freq');
            plottype = 'sweep:freq:angle';
            d = cap_sweep(lfile);
        else
            warning(['Unknown plottype for file: ' file '.  Plotting Defaults.']);
        end
        
        v = plot_me(d, plottype);
		figure(v);
		title(file,'Interpreter', 'none');
        pretty_plot;
	end

else    
   
    % if both arguments are defined, then plot the requested plottype
    plot_me(d, plottype);

end

%---------------------------------------------------
function v = plot_me(d, plottype);
	switch plottype
        case 'creep'
            v = creep_plots(d);
        case 'creep:all'
            v = creep_all(d);
        case 'viscometry'
            v = viscometry_plots(d);
        case 'viscometry:yield'
            v = yield_plots(d);
        case 'sweep:amp'
            v = sweep_amp(d);
        case 'sweep:amp:all'
            v = sweep_amp_all(d);
        case 'sweep:freq'
            v = sweep_freq(d);
        case 'sweep:freq:angle'
            v = sweep_freq_angle(d);
        otherwise
            error('cap_plot: Plot type unknown.');
    end
        
%---------------------------------------------------
function h = creep_plots(d);
    
    h = figure;
    plot(d.creep.time, d.creep.compliance, d.recovery.time + max(d.creep.time), d.recovery.compliance);
    title('Creep Recovery','Interpreter', 'none');
    xlabel('time [s]');
    ylabel('Compliance [1/Pa]');
    
    
%---------------------------------------------------    
function h = viscometry_plots(d);

    h = figure;
    loglog(d.shear_rate, d.viscosity);
    hold on;
        loglog(d.shear_rate(2), d.viscosity(2), '>');
    hold off;
    title('Viscometry','Interpreter', 'none');
    xlabel('Shear Rate [1/s]');
    ylabel('Viscosity [Pa s]');

    
%---------------------------------------------------    
function h = yield_plots(d);

    h = figure;
    plot(d.shear_stress, d.shear_rate);
    hold on;
        plot(d.shear_stress(2), d.shear_rate(2), '>');
    hold off;    
    title('Viscometry','Interpreter', 'none');
    xlabel('Shear Stress [Pa]');
    ylabel('Strain Rate [s^{-1}]');    
    pretty_plot;
    
%---------------------------------------------------    
function h = sweep_freq(d);

    h = figure;
    [ax,h1,h2] = plotyy(d.frequency, d.elastic_modulus, d.frequency, d.viscous_modulus, 'loglog');
    title('Frequency Sweep','FontSize',12,'FontWeight','bold','Interpreter', 'none');
    xlabel('Frequency [Hz]','FontSize',12,'FontWeight','bold');
    gpax = ax(1);
    gppax = ax(2);
    set(get(gpax,'YLabel'),'String','G'' [Pa]','FontSize',12,'FontWeight','bold');
    set(get(gppax,'YLabel'),'String','G'''' [Pa]','FontSize',12,'FontWeight','bold');
    set(gpax,'FontSize',12,'FontWeight','bold');
    set(gppax,'FontSize',12,'FontWeight','bold');

    % Make sure the two y-axes have same range for identifying crossovers.
    gpaxrange = diff(get(gpax, 'YLim'));
    gppaxrange = diff(get(gppax, 'YLim'));    
    if gpaxrange > gppaxrange
        set(gppax, 'YLim', get(gpax, 'YLim'));
    else 
        set(gpax, 'YLim', get(gppax, 'YLim'));
    end
    
function h = sweep_freq_angle(d);

    h = figure;

    [ax,h1,h2] = plotyy(d.frequency, [d.elastic_modulus./d.complex_modulus, d.viscous_modulus./d.complex_modulus], d.frequency, d.phaseangle, 'semilogx');
    title('Frequency Sweep','FontSize',12,'FontWeight','bold','Interpreter', 'none');
    xlabel('Frequency [Hz]','FontSize',12,'FontWeight','bold');
    set(get(ax(1),'YLabel'),'String','normalized modulus [Pa]','FontSize',12,'FontWeight','bold');
    set(get(ax(2),'YLabel'),'String','tan(\delta) [^o]','FontSize',12,'FontWeight','bold');
    set(ax(1), 'FontSize', 12, 'FontWeight', 'bold');
    set(ax(2), 'FontSize', 12, 'FontWeight', 'bold');
    
    legend('elastic', 'viscous');
    
%---------------------------------------------------    
function h = sweep_amp(d);

    h = figure;
    loglog(d.shear_stress, d.complex_modulus);
    hold on;
        loglog(d.shear_stress(2), d.complex_modulus(2), '>');
    hold off;
    title('Amplitude Sweep','Interpreter', 'none');
    xlabel('Shear Stress [Pa]');
    ylabel('Complex Modulus [Pa]');
    
%-------------------------------------------------
function h = sweep_amp_all(d);
    files = dir('*.xls');
    clr = 'brgkmcy';
    h = figure;
    hold on;
    
    clridx = 0;
	for k = 1 : length(files)
        
        file = files(k).name;
        file = lower(file);
        
        if strfind(file, 'amp')
            d = cap_sweep(file);
            loglog(d.shear_stress, d.complex_modulus, clr(mod(clridx,7)+1));
            hold on;
                loglog(d.shear_stress(2), d.complex_modulus(2), [clr(mod(clridx,7)+1) '>'], 'MarkerSize', '15');
			hold off;            
            clridx = clridx + 1;
        end
        
	end

    hold off;
	title('Amplitude Sweep','Interpreter', 'none');    
    xlabel('Shear Stress [Pa]');
    ylabel('|G*| [Pa]');    
    pretty_plot;

%-------------------------------------------------
function h = creep_all(d);
    files = dir('*.xls');
    clr = 'brgkmcy';
    h = figure;
    hold on;
    
    clridx = 0;
	for k = 1 : length(files)
        
        file = files(k).name;
        file = lower(file);
        
        if strfind(file, 'creep')
            d = cap_creep(file);
            semilogy(d.creep.time, d.creep.compliance, clr(mod(clridx,7)+1), ...
                 d.recovery.time+max(d.creep.time), d.recovery.compliance, clr(mod(clridx,7)+1));
            hold on;
        end
        clridx = clridx + 1;
        
	end

    hold off;
	title('Creep:All','Interpreter', 'none');    
    xlabel('time [sec]');
    ylabel('Compliance [1/Pa]');    
    pretty_plot;

    
        
