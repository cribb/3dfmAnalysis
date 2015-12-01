function track = tracking_analysis(comptrackdata)
%create subfunctions for each value being calculated

data = sortrows(comptrackdata,2);
numframes = max(data(:,1));

matched_traj = zeros(numframes,1);
track_eff = zeros(numframes,1);
extraA = zeros(numframes,1);
extraB = zeros(numframes,1);
fraction_untracked = zeros(numframes,1);
artifactor = zeros(numframes,1);
errorx = zeros(numframes,1);
errory = zeros(numframes,1);
matched_traj_overall = 0;
total_traj_man_overall = 0;

for fr = 1:numframes %took away +1
    matched_traj_fr = 0;
    extraA_fr = 0;
    extraB_fr = 0;
    for n = 1:length(data)
        if data(n,1) == fr && ~isnan(data(n,2)) && ~isnan(data(n,3)) %changed fr-1 to fr for these statements
            matched_traj_fr = matched_traj_fr + 1;
        elseif data(n,1) == fr && isnan(data(n,3)) %if B has no matching location, there is an extra one in A
            extraA_fr = extraA_fr + 1;
        elseif data(n,1) == fr && isnan(data(n,2)) %if A has no matching location, there is an extra one in B
            extraB_fr = extraB_fr + 1; 
        end
    end
    
    matched_traj(fr) = matched_traj_fr;
    matched_traj_overall = matched_traj_overall + matched_traj_fr;
    extraA(fr) = extraA_fr;
    extraB(fr) = extraB_fr; 
    total_traj_man_fr = matched_traj_fr + extraA_fr; 
    total_traj_man_overall = total_traj_man_overall + total_traj_man_fr;
    
    track_eff(fr) = matched_traj_fr/total_traj_man_fr;
    fraction_untracked(fr) = extraA_fr/total_traj_man_fr;
    artifactor(fr) = extraB_fr/total_traj_man_fr;
    
    thesepoints = data(:,1) == fr;
    errorx_vector = data(thesepoints,12);
    errorx_vector = errorx_vector(~isnan(errorx_vector));
    errory_vector = data(thesepoints,13);
    errory_vector = errory_vector(~isnan(errory_vector));
    
    errorx(fr) = mean(errorx_vector);
    errory(fr) = mean(errory_vector);
end

% 
% for i = 1:length(comptrackdata(:,1))
%     if ~isnan(data(i,2)) && ~isnan(data(i,3))
%         matched_traj = matched_traj + 1;
%     elseif isnan(data(i,3)) %if B has no matching location, there is an extra one in A
%         extraA = extraA + 1;
%     elseif isnan(data(i,2)) %if A has no matching location, there is an extra one in B
%         extraB = extraB + 1; 
%     end
% end

%could do this with a sum of logicals using isnan?
% real_Adata = ~isnan(data(:,2)); %which are not NaNs
% total_traj_man = sum(real_Adata);
% 
% artifactor = extraB/total_traj_man;
% 
% track_eff = matched_traj/total_traj_man;
% 
% use_diff = ~isnan(data(:,12));
% xstd = data(:,12);
% ystd = data(:,13);
% xstdABdiff = xstd(use_diff);
% ystdABdiff = ystd(use_diff);
% errorx = mean(xstdABdiff(:));
% errory = mean(ystdABdiff(:));

track.track_eff = track_eff;
track.avg_track_eff = mean(track_eff);
track.overall_track_eff = matched_traj_overall/total_traj_man_overall;
%track.extraA = extraA;
%track.extraAtotal = sum(extraA(:));
%track.extraB = extraB;
%track.extraBtotal = sum(extraB(:));
track.fraction_untracked = fraction_untracked;
track.avg_untracked = mean(fraction_untracked);
track.overall_untracked = (total_traj_man_overall - matched_traj_overall)/total_traj_man_overall;
track.artifactor = artifactor;
track.avg_artifactor = mean(artifactor);
track.errorx = errorx;
track.avg_errorx = mean(errorx);
track.errory = errory;
track.avg_errory = mean(errory);
end