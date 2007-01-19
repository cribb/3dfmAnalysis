function Ftable = varforce_compute_inst_force(tablein, params)
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/06 (jcribb)
%
% varforce_compute_inst_force computes force using instantaneous velocity 
% method.  This essentially takes a windowed derivative of specified size
% of the displacement data versus time.  This yields the bead velocity
% which is then processed through Stokes law to compute the 'instantaneous' 
% force.
%
%   Ftable = varforce_compute_inst_force(tablein, params)
%
% where Ftable contains the force values for each bead at each new grid
% location.
% 
%

    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;
    
    varforce_constants;
    
    voltages    = params.voltages;
    viscosity   = params.calibrator_viscosity;
    bead_radius = params.bead_radius * 1e-6;
    poleloc     = params.poleloc; 
    window_size = params.window_size;   
	
    % for each beadID, compute its velocity:magnitude and force:magnitude.
    available_trackers = unique(tablein(:,ID))';
	for myTracker = available_trackers
        tic;

        % reduce to current bead
        this_bead = get_bead(tablein, myTracker);

        for mySeq = unique(this_bead(:,SEQ))' 

            % reduce to current sequence
            SEQidx = find(this_bead(:,SEQ) == mySeq);
            
            for myVoltage = unique(this_bead(SEQidx,VOLTS))'

                % reduce bead to the points taken at mth voltage
                VOLTSidx = find(this_bead(SEQidx,VOLTS) == myVoltage);

                t = this_bead(VOLTSidx,TIME);
                xy = this_bead(VOLTSidx, X:Y);
                
                [newxy,force] = forces2d(t, xy, viscosity, bead_radius, window_size);
               
                % setup the output force table
                if length(force) > 0
                    if ~exist('Ftable');  
                        Ftable = [newxy force repmat([mySeq myVoltage],size(newxy,1),1)];
                    else
                        Ftable = [Ftable ; newxy force repmat([mySeq myVoltage],size(newxy,1),1)];
                    end
                end
                
            end
        end

        % handle timer
        itertime = toc;
        if myTracker == available_trackers(1)
            totaltime = itertime;
        else
            totaltime = totaltime + itertime;
        end    
        meantime = totaltime / (myTracker + 1);
        timeleft = ( length(available_trackers) - myTracker) * meantime;
        outs = [num2str(timeleft, '%5.0f') ' sec.'];
        set(timetext, 'String', outs);
        drawnow;
	end
    
    close(timefig);
    
    
