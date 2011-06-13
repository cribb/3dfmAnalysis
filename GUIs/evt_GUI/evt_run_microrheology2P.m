% TODO
% get computational number for imagdiag
% cd back to data folder after running
% fix the close all so gui remains active
% creates possibly unwanted folders

function [omega,Gp,Gpp,MSD,Tau] = evt_run_microrheology2P(homefolder,basepath,beadID,Frame,x,y,timestep,beadradius,imagediag,temp)

FOVs = 1;

ddposum = [x y Frame beadID];

mkdir(basepath,'Bead_Tracking\ddposum_files')
save([basepath 'Bead_Tracking\ddposum_files\' 'ddposum_run' '1' '.mat'],'ddposum')

number_of_frames = max(ddposum(:,3));

cd(homefolder)
% cd Dedriftingandconversions
getting_individual_beads(basepath,FOVs);

    cd(homefolder)
%     cd Two_point
    
    separating_beads_by_FOV( basepath);
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % twopoint parameters
    
    % minimum and maximum separation distance in micrometers to compute the
    % correlation
    rmin = 4*beadradius;                            % set to four times the bead radius
    rmax = imagediag;                               % set to the image diagonal length
    
    % number of log spaced bins between the two boundaries (arbitrarily
    % picked)
    nbrbins = 20;
    
    % maximum time (in frames) over which to compute the correlation
    maxtime = 1000000;
    
    % time interval between frames, in seconds
    timestep = timestep;
    
    % dimensionality of data (always 2)
    dim = 2;
    
    % optional vector of dt's for which the correlations should be computed
    % (0 has program create a logarithmically spaced vector)
    mydts = 0;
    
    % set to zero since dedrifting already done
    dedrift = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Executing twopoint
    
    load( [basepath '2pt_msd\beads_separated_by_FOV.mat'] );
    [data] = twopoint( posstot, [rmin, rmax, nbrbins, maxtime], timestep, dim, mydts, dedrift );
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calling_two_fitting methods parameters
    % minimum and maximum separatoin distances (in micrometers) to be
    % included in the fit
    minradius(1:size(data,1))=0;
    maxradius(1:size(data,1))=rmax;
    
    % Boolean 1: display some results as output, 0: Don't display results
    displaying = 0;
    
    % Boolean set to 1 to save 2P MSD information
    savingmsdd = 1;
    
    % Boolean set to 1 to save plots of the fitting results
    savingplot = 0;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Executing calling_two_fitting_methods
    for j = 1:size(data,1)
        calling_two_fitting_methods( basepath, data, j, minradius(j), maxradius(j), displaying, beadradius, savingmsdd, savingplot );
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % calc_G parameters

    % bead radius
    a = beadradius;
    
    % dimension of data
    dim = 2;
    
    % Temperature in Kelvin
    T = temp;
    
    % fraction of G(s) below which G'(w) and G''(w) are meaningless
    % (recommended 0.03)
    clip = 0.03;
    
    % width of the Gaussian that is used for the polynomial fit
    % (recommended starting value 0.7, increase for noisier data)
    width = 0.7;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Running calc_G
    cd([basepath 'rDrr_rDqq_figs\'])
    TempMat = open('msd2P.mat');
    msd2P = TempMat.msd2P;
    MSD = msd2P;
    
    cd(homefolder)
%     cd Moduli
    
    [omega,Gs,Gp,Gpp,dd,dda] = calc_G( msd2P(:,1,1),msd2P(:,4,1),a,dim,T,clip,width);