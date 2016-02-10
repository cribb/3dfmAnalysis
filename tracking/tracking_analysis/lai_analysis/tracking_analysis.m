function [byframe, byparticle] = tracking_analysis(comptrackdata)

data = sortrows(comptrackdata,2);
numframes = max(data(:,1));


[track_eff_frame,track_eff_avg,track_eff_video] = tracking_efficiency(data,numframes);

[fraction_untracked_frame,fraction_untracked_avg,fraction_untracked_video] = untracked(data,numframes);

[artifactor_frame,artifactor_avg] = artifactor(data,numframes);

[errorx_frame,errorx_avg,errory_frame,errory_avg] = position_error(data,numframes);


byframe.track_eff = track_eff_frame;
byframe.avg_track_eff = track_eff_avg;
byframe.overall_track_eff = track_eff_video;

byframe.fraction_untracked = fraction_untracked_frame;
byframe.avg_untracked = fraction_untracked_avg;
byframe.overall_untracked = fraction_untracked_video;

byframe.artifactor = artifactor_frame;
byframe.avg_artifactor = artifactor_avg;

byframe.errorx = errorx_frame;
byframe.avg_errorx = errorx_avg;
byframe.errory = errory_frame;
byframe.avg_errory = errory_avg;

byparticle = particle_efficiency(data);

end

% ----------------------------- Subfunctions -----------------------------

function [track_eff_frame,track_eff_avg,track_eff_video] = tracking_efficiency(data,numframes)

matched_traj = zeros(numframes,1);
track_eff = zeros(numframes,1);

matched_traj_overall = 0;
total_traj_man_overall = 0;

for fr = 1:numframes %took away +1
    extraA_fr = 0;
    matched_traj_fr = 0;
    for n = 1:length(data)
        if data(n,1) == fr && ~isnan(data(n,2)) && ~isnan(data(n,3)) %changed fr-1 to fr for these statements
            matched_traj_fr = matched_traj_fr + 1;
        elseif data(n,1) == fr && isnan(data(n,3)) %if B has no matching location, there is an extra one in A
            extraA_fr = extraA_fr + 1;
        end
    end
    
    matched_traj(fr) = matched_traj_fr;
    matched_traj_overall = matched_traj_overall + matched_traj_fr;
    total_traj_man_fr = matched_traj_fr + extraA_fr; 
    total_traj_man_overall = total_traj_man_overall + total_traj_man_fr;
    
    track_eff(fr) = matched_traj_fr/total_traj_man_fr;
end

subplot(2,2,1);
plot(track_eff);
title('Tracking Efficiency vs Frame Number');
xlabel('Frame Number');
ylabel('Tracking Efficiency');

track_eff_frame = track_eff;
track_eff_avg = mean(track_eff(:));
track_eff_video = matched_traj_overall/total_traj_man_overall;

end

function [fraction_untracked_frame,fraction_untracked_avg,fraction_untracked_video] = untracked(data,numframes)

fraction_untracked = zeros(numframes,1);
matched_traj_overall = 0;
total_traj_man_overall = 0;

for fr = 1:numframes %took away +1
    matched_traj_fr = 0;
    extraA_fr = 0;
    for n = 1:length(data)
        if data(n,1) == fr && ~isnan(data(n,2)) && ~isnan(data(n,3)) %changed fr-1 to fr for these statements
            matched_traj_fr = matched_traj_fr + 1;
        elseif data(n,1) == fr && isnan(data(n,3)) %if B has no matching location, there is an extra one in A
            extraA_fr = extraA_fr + 1;
        end
    end
    
    matched_traj_overall = matched_traj_overall + matched_traj_fr;
    total_traj_man_fr = matched_traj_fr + extraA_fr; 
    total_traj_man_overall = total_traj_man_overall + total_traj_man_fr;

    fraction_untracked(fr) = extraA_fr/total_traj_man_fr;
    
    fraction_untracked_frame = fraction_untracked;
    fraction_untracked_avg = mean(fraction_untracked(:));
    fraction_untracked_video = (total_traj_man_overall - matched_traj_overall)/total_traj_man_overall;

end
end

function [artifactor_frame,artifactor_avg] = artifactor(data,numframes)

artifactor = zeros(numframes,1);
%total_traj_man_fr = 0;

for fr = 1:numframes %took away +1
    extraB_fr = 0;
    extraA_fr = 0;
    matched_traj_fr = 0;
    for n = 1:length(data)
        if data(n,1) == fr && ~isnan(data(n,2)) && ~isnan(data(n,3)) %changed fr-1 to fr for these statements
            matched_traj_fr = matched_traj_fr + 1;
        elseif data(n,1) == fr && isnan(data(n,2)) %if A has no matching location, there is an extra one in B
            extraB_fr = extraB_fr + 1; 
        elseif data(n,1) == fr && isnan(data(n,3)) %if B has no matching location, there is an extra one in A
            extraA_fr = extraA_fr + 1;
        end
    end
    total_traj_man_fr = matched_traj_fr + extraA_fr;
    artifactor(fr) = extraB_fr/total_traj_man_fr;
end
    

subplot(2,2,2);
plot(artifactor);
title('Artifactor vs Frame Number');
xlabel('Frame Number');
ylabel('Artifactor');
artifactor_frame = artifactor;
artifactor_avg = mean(artifactor(:));

end

function [errorx_frame,errorx_avg,errory_frame,errory_avg] = position_error(data,numframes)

errorx = zeros(numframes,1);
errory = zeros(numframes,1);

for fr = 1:numframes
    thesepoints = data(:,1) == fr;
    errorx_vector = data(thesepoints,12);
    errorx_vector = errorx_vector(~isnan(errorx_vector));
    errory_vector = data(thesepoints,13);
    errory_vector = errory_vector(~isnan(errory_vector));
    
    errorx(fr) = mean(errorx_vector);
    errory(fr) = mean(errory_vector);
end

errorx_frame = errorx;
errorx_avg = mean(errorx(:));
errory_frame = errory;
errory_avg = mean(errory(:));

end


function table = particle_efficiency(data)

%sort the data by ID in A
%data_byparticle = sortrows(data,2);

%list the IDs found in A
orig_particleIDs = unique(data(:,2));
keep = ~isnan(orig_particleIDs);
orig_particleIDs = orig_particleIDs(keep);
particle_eff = zeros(size(orig_particleIDs));
B_IDs = cell.empty(0,length(orig_particleIDs));

for m = 1:length(orig_particleIDs)
    ID = orig_particleIDs(m);
    
    %How many frames does that ID appear in A?
    ID_found = (data(:,2) == ID);
    dataforID = data(ID_found,:);
    expected_frames_p = length(dataforID);
    
    %How many of those were matched with an ID in B?
    onlymatched = ~isnan(dataforID(:,3));
    matcheddata = dataforID(onlymatched,:);
    
    s = size(matcheddata);
    matched_frames_p = s(1);
    
    %Particle efficiency = matched/expected;
    particle_eff_p = matched_frames_p/expected_frames_p;
    
    particle_eff(m) = particle_eff_p;
    
    %Which IDs in B were matched with this ID from A?
    B_IDs_p = matcheddata(:,3);
    B_IDs_p = unique(B_IDs_p);
    
    if isempty(B_IDs_p)
        B_IDs{m} = NaN;
    else B_IDs{m} = B_IDs_p;
    end
    
end

B_IDs = transpose(B_IDs);
orig_particleIDs = num2cell(orig_particleIDs);
particle_eff = num2cell(particle_eff);

table = horzcat(orig_particleIDs,particle_eff,B_IDs);

end