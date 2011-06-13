% TSM NOTES
% Does the function care about dropped beads?
%       The frame number goes into posstot, can start or end wherever, so
%       it appears no
% ??? If a bead is dropping in and out of the bead tracker, it is
%       presumably still affecting the motion of the other beads (according to
%       2pt), how do we account for that?
% ??? How big is our screen? (i.e. do we need to change the number from
%       800?)
% ??? What is the units of the x y data given (for water)?
function [omega,Gp,Gpp,MSD] = run_microrheology(basepath,basefile,FOVs,timestep,P,maxtime,beadradius,imagediag,temp)
% Input:
%       basepath: path to the root folder of the experiment (should end in
%           '\'
%       basefile: filename containing matrix up to the number, assuming form
%           [basefile ## .raw.vrpn.evt.mat]
%           Matrix contained in basefile has columns:
%           [--, bead#, frame#, x (microm), y (microm)]
%            Matrix = tracking.spot3DSecUsecIndexFramenumXYZRPY
%       FOVs: vector of numbers to be processed (1 will be 01, 2 -> 02)
%       timeint: time interval between frames in seconds
%       P: P = 1 for 1P calculation, P = 2 for 2P calculation
%       maxtime: maximum time in seconds to be output
%       beadradius: bead radius in micrometers
%       imagediag: length of the diagonal of the image (in micrometers)
%       temp: temperature in Kelvin

homefolder = pwd;

[number_of_frames] = mat_recolumn(basepath,basefile,FOVs);

cd Dedriftingandconversions
getting_individual_beads(basepath,FOVs);

if P == 1
    cd(homefolder)
    cd MSD
    timeint = timestep;
    number_of_frames = 1200;
    [MSD, tau] = Mean_SD_many_single_beads( basepath, timeint, number_of_frames);
    
    [msdtau] = making_logarithmically_spaced_msd_vs_tau( MSD, tau, maxtime );
    
    % Calculating moduli
    
    cd homefolder
    cd Moduli
    
    % dim set to 2 because the data is done only for x and y
    dim = 2;
    % clip set to 0.03 to eliminate meaningless error
    clip = 0.03;
    % recomended starting value of width is 0.7, but can be increased for
    % noiser data
    width = 0.7;
    
    a = beadradius;
    
    [omega,Gs,Gp,Gpp,dd,dda] = calc_G(msdtau(:,1), msdtau(:,2),a,dim,T,clip,width);
elseif P == 2
    cd(homefolder)
    cd Two_point
    
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
    savingplot = 1;
    
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
    MSD = msd2P(:,2,1);
    
    cd(homefolder)
    cd Moduli
    
    [omega,Gs,Gp,Gpp,dd,dda] = calc_G( msd2P(:,1,1),msd2P(:,4,1),a,dim,T,clip,width);
else
    error('Invalid input for P')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    