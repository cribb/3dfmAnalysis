function pan_mucus_rheo_run(metafile)

load(metafile);

zz1 = tic;

sample_code = [conc well pass lumthreshold];


% construct evt files if they are not present
if make_evts
    
    for k = 1:length(vrpnfilelist);
        zz = tic;
            % outfile = SetFPSandMinFrames(filemask, frameRate, minFrames, minPixels, tcrop, xycrop)
            setFPSandMinFrames(vrpnfilelist(k).name, 30, 150, 2, 2, 0);
        toc(zz);
    end

    beep;
    sendmail('jcribb@email.unc.edu', 'matlab run is finished (n/t)', 'done, fool');
    
end


if trim_luminance
    
    for k = 1:length(evtfilelist)
        
        myname = evtfilelist(k).name;
        
        d = load_video_tracking(myname, frame_rate, [], [], 'absolute', 'no', 'table');
        
        MIPfile = strrep(myname, 'vrpn.evt.mat', 'composite.tif');
        
        MIPim = imread(MIPfile, 'tif');
        
          [b e] = regexp(myname, 'well');
          mywell = str2num(myname(e+1));

          [b e] = regexp(myname, 'pass');
          mypass = str2num(myname(e+1));
        
          mylum = find( well == mywell & pass == mypass );
          
        [filtdata, all_data, badbeadlist] = filter_bead_aggregates(d, MIPim, lumthreshold(mylum), 1.3);
        
        tracking.spot3DSecUsecIndexFramenumXYZRPY = filtdata;
        
        save(myname, 'tracking');
        
        clear tracking;
        
    end
end
%
% run analyses on each dataset and begin compiling results
%

if compute_msd
    evtfilelist = dir('mucus_rheo_run*.vrpn.vrpn.evt.mat');

    tauout    = NaN(length(win), length(evtfilelist));
    msdout    = NaN(length(win), length(evtfilelist));
    errout    = NaN(length(win), length(evtfilelist));
    freqout   = NaN(length(win), length(evtfilelist));
    etaout    = NaN(length(win), length(evtfilelist));
    etaerrout = NaN(length(win), length(evtfilelist));

    for k = 1:length(evtfilelist)    
%        fprintf('k = %d \n', k);
    %      subplot(2,2,1); hold on; plot(v(:,X), v(:,Y), '.r'); hold off;

          myname = evtfilelist(k).name;      

          [b e] = regexp(myname, 'well');
          mywell = str2num(myname(e+1));

          [b e] = regexp(myname, 'pass');
          mypass = str2num(myname(e+1));

          vmsd = video_msd(myname, win, frame_rate, calib_um, 'no', 1);
          
%           vmsd.tau = mean(vmsd.tau,2);
%           vmsd.msd = mean(vmsd.msd,2);
          
          myve = ve(vmsd, bead_radius,'f','no', 1);
    
          h = figure(99);
          plot_msd(vmsd,h,'ame');
          gen_pub_plotfiles([myname '.msd'], h, 'normal');           
            
          q = figure(100);
          plot_ve(myve, 'f', q, 'N');

          logtau = log10(vmsd.tau);
          logmsd = log10(vmsd.msd);

          mean_logtau = nanmean(logtau,2);
          mean_logmsd = nanmean(logmsd,2);

          ste_logmsd = nanstd(logmsd,[],2) ./ sqrt(vmsd.n);

          concout(1,k) = conc( find( well == mywell & pass == mypass ));

          fprintf('k=%i, size(logtau)=[%i %i], size(logmsd)=[%i %i], size(mean_logtau)=[%i %i], size(ste_logmsd)=[%i %i]\n', ...
                   k, ...
                   size(logtau,1), size(logtau,2), ...
                   size(logmsd,1), size(logmsd,2), ...
                   size(mean_logtau,1), size(mean_logtau,2), ...
                   size(ste_logmsd,1), size(ste_logmsd,2));                      
                           
          tauout(1:length(mean_logmsd),k) = mean_logtau(:); 
          msdout(1:length(mean_logmsd),k) = mean_logmsd(:);
          errout(1:length(ste_logmsd),k) = ste_logmsd(:);
          freqout(1:length(myve.f),k) = myve.f(:);
          etaout(1:length(myve.nstar),k) = sqrt(myve.np(:).^2 + myve.npp(:).^2);
          etaerrout(1:length(myve.error.nstar),k) = sqrt(myve.error.np(:).^2 + myve.error.npp(:).^2);

    end
    
    save('saved_workspace.mat');
else
    load('saved_workspace.mat');
end

% figure out sorting crap
[concout, IDX] = sort(concout, 2, 'ascend');
tauout = tauout(:,IDX);
msdout = msdout(:,IDX);
etaout = etaout(:,IDX);
etaerrout = etaerrout(:,IDX);


idx = (log10(freqout(:,1)) >= freq_cutoff);
freqout = freqout( idx, :);
etaout  =  etaout( idx, :);
etaerrout = etaerrout(idx,:);

idx = (etaerrout >= etaout);
etaout(idx) = NaN;
etaerrout(idx) = NaN;


% carreau fits
if carreau_fits
    mean_freqout = nanmean(freqout,2);
    range_freqout  = max(mean_freqout) - min(mean_freqout);
    
    interp_freqout = [min(freqout) : range_freqout / 100 : max(freqout)]';
        
    interp_etaout = interp1(mean_freqout, etaout, interp_freqout);
    interp_etaerrout = interp1(mean_freqout, etaerrout, interp_freqout);
    
    
    interp_freqout = repmat(interp_freqout, 1, size(interp_etaout,2));
    
    weights = 1 - abs(interp_etaerrout ./ interp_etaout);    
    
    
    for k = 1:length(concout)    
        idx = ( isfinite(interp_freqout(:,k)) & isfinite(interp_etaout(:,k)) & isfinite(weights(:,k)));

        q = tic;
            ncf = new_carreau_fit(interp_freqout(idx,k), interp_etaout(idx,k), weights(idx,k), 'n');
            eta_zero(k,:) = ncf.eta_zero;
            eta_inf(k,:) = ncf.eta_inf;
            lambda(k,:) = ncf.lambda;
            m(k,:) = ncf.m;
            n(k,:) = ncf.n;
            % [eta_zero(k), eta_inf(k), lambda(k), m(k), n(k), R_square(k), eta_fit] = carreau_model_fit(freqout(idx,k), etaout(idx,k), 'n');
        q = toc(q);
        fprintf('carreau k=%i, size(idx)=[%i %i], time elapsed= %f \n', k, size(idx,1), size(idx,2), q);
    end
end

      h = figure; 
          errorbar(tauout, msdout, errout); 
          xlabel('\tau, [s]');
          ylabel('<r^2> [m^2/s]');
          legend(num2str(concout(:)));
    %       pretty_plot;
          gen_pub_plotfiles('all_mean_msds', h, 'normal');
      
      h = figure; 
    %       plot(log10(fliplr(freqout)), log10(fliplr(etaout)), '.-');
          errh = log10(fliplr(etaout)+fliplr(etaerrout))-log10(fliplr(etaout));
          errorbar(log10(fliplr(freqout)), log10(fliplr(etaout)), errh, '.-'); 
          xlabel('freq, [Hz]');
          ylabel('|\eta^*| [Pa s]');
          legend(num2str(flipud(concout(:))));
    %       pretty_plot;
          gen_pub_plotfiles('viscosity_vs_frequency', h, 'normal');

      h = figure;
          plot(log10(concout), log10(etaout([1 end],:)), '.');
          legend(num2str(freqout([1 end],1)));
          xlabel('conc %');
          ylabel('|\eta^*| [Pa s]');
    %       pretty_plot;
          gen_pub_plotfiles('viscosity_vs_concentration', h, 'normal');
      
      h = figure; 
          fits_gammadot = [1e-4:1e-4:9e-4, 1e-3:1e-3:9e-3, 0.01:0.01:0.09, 0.1:0.1:0.9, 1:9, 10:10:90, 100];
          eta_zero_ = repmat(eta_zero(:,2), 1, length(fits_gammadot));
          eta_inf_  = repmat(eta_inf(:,2), 1, length(fits_gammadot));
          m_ = repmat(m(:,2), 1, length(fits_gammadot));
          n_ = repmat(n(:,2), 1, length(fits_gammadot));
          lambda_ = repmat(lambda(:,2), 1, length(fits_gammadot));
          fits_gammadot = repmat(fits_gammadot, length(eta_zero(:,2)), 1);
          fits_etas = (eta_zero_ - eta_inf_) .* ( (1+ (lambda_ .* fits_gammadot).^m_) .^ ((n_-1)./m_)) + eta_inf_;

          errorbar(log10(fliplr(freqout)), log10(fliplr(etaout)), errh, '.'); 
          xlabel('freq, [Hz]');
          ylabel('|\eta^*| [Pa s]');
          legend(num2str(flipud(concout(:))));

          hold on;
              plot(fliplr(log10(fits_gammadot)'), fliplr(log10(fits_etas)'));
          hold off;
          
          gen_pub_plotfiles('viscosity_vs_shearrate_carreau_fit', h, 'normal');
          
      h = figure;
         % plot(log10(concout), log10(eta_zero(:,2)), '.');
          errhcar = log10(eta_zero(:,3)) - log10(eta_zero(:,2));
          errorbar(log10(concout), log10(eta_zero(:,2)), errhcar, '.');
          title('Carreau fits, \eta_o');
          xlabel('conc %');
          ylabel('|\eta^*| [Pa s]');
    %       pretty_plot;
          gen_pub_plotfiles('viscosity_vs_concentration_carreau_fit', h, 'normal');
      
toc(zz1);

