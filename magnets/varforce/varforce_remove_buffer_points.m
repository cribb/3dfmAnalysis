function tableout = varforce_remove_buffer_points(table, num_buffer_points)
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/2006 
%  
% Utility function used in varforce technique for calibrating 3dfm.
% Removes the edge points between voltage shifts in an attempt to reduce
% crosstalk due to inconsistant timing issue.  The input variable is a
% table obained from load_video_tracking and the parameter list obtained
% from the varforce_cal_drive gui.  The output is the reduced video
% tracking data table.
%  
%  [tableout] = varforce_remove_buffer_points(table, num_buffer_points)
%   
%  where "table" is the matrix (table) output of load_video_tracking 
%        "num_buffer_points" is the number of position points to remove on 
%                            each side of the voltage changes.
%   

varforce_constants;


if num_buffer_points > 0
    
    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;

    trackers = unique(table(:,ID))';
    
    for myTracker = 1:length(trackers)

        tic;

        for mySeq = unique(table(:,SEQ))';
            for myVoltage = unique(table(:,VID))';
                   idx = find( table(:,ID)    == trackers(myTracker) & ...
                               table(:,SEQ)   == mySeq & ...
                               table(:,VID) == myVoltage );

                    minitable = table(idx,:);

                    if ~exist('newtable')
                        newtable = minitable(num_buffer_points : end - num_buffer_points, :);
                    else
                        newtable = [newtable ; minitable(num_buffer_points : end - num_buffer_points, :)];
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
    drawnow;

else
    
    newtable = table;

end
if exist('newtable') == 0
    newtable = table;
end

tableout = newtable;

