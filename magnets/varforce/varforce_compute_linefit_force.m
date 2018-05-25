function out = varforce_compute_linefit_force(varargin)
% VARFORCE_COMPUTE_LINEFIT_FORCE Computes force experienced by each bead with line fit
%
% 3DFM function  
% magnets/varforce
% last modified 11/17/08 (krisford)
%  
% Compute the force experienced by each bead by line-fitting displacements to
% compute velocities for many pulses in many sequences.
%  
%  [out] = varforce_compute_linefit_force(varargin)
%                                       
%  usage: 
%  
%  [out] = varforce_compute_linefit_force(tablein, params)
%  [out] = varforce_compute_linefit_force(tablein, params, error_tol)
%
%  where tablein is the varforce data matrix (slightly modified video matrix)
%        params is the varforce parameters structure
%        error_tol is a bypass error tolerance value (useful for relaxing error
%                  tolerance constraints when looking at drift or VERY small forces)
% 

switch nargin
    case 2
        tablein = varargin{1};
        params  = varargin{2};
        error_tol = params.error_tol;
    case 3
        tablein = varargin{1};
        params  = varargin{2};
        error_tol = varargin{3};
        logentry(['Bypassing requested error tolerance and using ' num2str(error_tol) '.']);
    otherwise
        error('Invalid arguments used to call varforce_compute_linefit_force.');
end

    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;
   
    varforce_constants;

    voltages    = params.voltages;
    viscosity   = params.calibrator_viscosity;
    bead_radius = params.bead_radius * 1e-6;
    calib_um    = params.calibum;
    poleloc     = params.poleloc;
	trackers    = unique(tablein(:,ID))';
    
	for myTracker = 1:length(trackers)
        tic;
        
        for mySeq = unique(tablein(:,SEQ))' 
            
            for myVID = unique(tablein(:,VID))'

                if ~exist('mycount')
                    mycount = 1;
                end
                
                idx = find( tablein(:,ID) == trackers(myTracker) ...
                          & tablein(:,SEQ) == mySeq ...
                          & tablein(:,VID) == myVID);

                if length(idx) > 1
                    
                    t = tablein(idx,TIME);
                    x = tablein(idx,X);
                    y = tablein(idx,Y);

                    try
                        warning off;
                            vxfit = flipud(robustfit(t, x));
                            vyfit = flipud(robustfit(t, y));
                        warning on;
                    catch
                            vxfit = polyfit(t, x, 1);
                            vyfit = polyfit(t, y, 1);
                            logentry('Not enough data for robust fit.  Using regular polyfit instead.');
                    end

                    % uncertainty in velocity determination
                    xerr = uncertainty_in_linefit(t, x, vxfit);
                    yerr = uncertainty_in_linefit(t, y, vyfit);                    
                    
                    vxerr = xerr(1);
                    vyerr = yerr(1);
                    
                    % scalar for converting velocity to force
                    drag_coeff = 6*pi * viscosity * bead_radius;                    

                    % rms of the residuals
                    xres = rms(x - polyval(vxfit, t));
                    yres = rms(y - polyval(vyfit, t));
                    xyres = [xres yres];

                    xy = [mean(x) mean(y)];                    

                    % convert everything to force space
                    Fxfit  = drag_coeff * vxfit;
                    Fyfit  = drag_coeff * vyfit;
                    Fxyerr = drag_coeff * [vxerr vyerr];                                                          
                    Fxy    = drag_coeff * [vxfit(1) vyfit(1)];                    
                    
                    % compute error percent which is used to threshold
                    % acceptable data via the error_tol value.
                    if ( vxfit(1) ~= 0 )
                        xerrpct = abs(vxerr / vxfit(1));
                    else
                        xerrpct = NaN;
                        logentry('x-slope is zero.  Reporting NaN for Error');
                    end
                    
                    if ( vyfit(1) ~= 0 )
                        yerrpct = abs(vyerr / vyfit(1));
                    else
                        yerrpct = NaN;
                        logentry('y-slope is zero.  Reporting NaN for Error');
                    end
                    
                else

                    vxfit    = NaN; vyfit    = NaN; 
                    xres     = NaN; yres     = NaN; 
                    xerrpct  = NaN; yerrpct  = NaN;
                    newx     = NaN; newy     = NaN; 
                    Fx       = NaN; Fy       = NaN;
                    
                end
                
                if ~isnan(xerrpct) && ~isnan(yerrpct)
                    
                    if (xerrpct < error_tol) && (yerrpct < error_tol)
                        
                        out.trackerid(mycount,1)   = myTracker;
                        out.seqid(mycount,1)       = mySeq;
                        % myVID
                        out.volts(mycount,1)       = voltages(myVID+1);
                        out.xy(mycount,:)          = xy;
                        out.xyslope(mycount,:)     = [vxfit(1) vyfit(1)];
                        out.xyintercept(mycount,:) = [vxfit(2) vyfit(2)];
                        out.xyres(mycount,:)       = xyres;
                        out.Fxy(mycount,:)         = Fxy;
                        out.Fxyerr(mycount,:)      = Fxyerr;

                        mycount = mycount + 1;
                    end
                end

            end
        end                 
                
        % handle timer
        itertime = toc;
        if ~exist('totaltime')
            totaltime = itertime;
        else
            totaltime = totaltime + itertime;
        end    
        meantime = totaltime / myTracker;
        timeleft = ( length(trackers) - myTracker) * meantime;
        outs = [num2str(timeleft, '%5.0f') ' sec.'];
        set(timetext, 'String', outs);
        drawnow;
    end
    
    close(timefig);
    
    % comment on why we have to do this
    if mycount <= 1 
        error('Analysis Error: No points within error tolerance for linefit estimates.');
        return;
    end

%%%%
%% extraneous functions
%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforce_compute_linefit_force: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return    
