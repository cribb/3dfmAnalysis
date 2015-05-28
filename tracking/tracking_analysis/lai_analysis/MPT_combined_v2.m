function MPT_combined_v2(filename,sheetname,conversion,frame_rate,min_frames,duplicate_cutoff)
% filename = Excel file with file extension ('file.xls' or 'file.xlsx')
% conversion = # um/pixel
% frame_rate = # frames/sec, CANNOT BE < 4 (o/w need to change stuck/moving
% classification part of code)
% min_frames = minimum # of frames for inclusion in analysis
% duplicate_cutoff = MSD cutoff value (um2) for removing duplicate
% particles; if 0, then no duplicate removal

% Input data must have following format: 1st column = Object #; 2nd column
% = Frame # (or "Image Plane"); 3rd column = X; 4th column = Y

% HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (note didn't keep track of changes before this)
% 1/1/13: Remove shift correction feature (will be kept separate)
% 1/1/13: Change definition of stuck vs. moving particles to be based on
% log10Deff at t = 1s
% 1/1/13: Compared various MPT_combined_v2 versions to consolidate
% 6/18/13: Edit to handle IDL skipped frames (borrow from Ben's code)
% 12/3/13: Change so that stuck vs. moving is based on log10Deff at t =
% 0.067s if min frames < 15
% 12/12/13: Fixed line in duplicate removal, indexing of duplicates for
% removal was not correct..
% 3/29/14: Change duplicate removal so value is in um2 rather than pixels2
% 4/14/14: Changed definition of stuck/moving to t=0.2667 s and cutoff=-1.5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ INPUT DATA FROM EXCEL & FORMAT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = xlsread(filename,sheetname); % Trajectory data
% Format to remove 0 0 0 0 line if there is one (sometimes happens for VST)
if A(1,:) == zeros(1,4)
    A = A(2:end,:);
end

% Format frames to start at 1 if needed
index = find(A(:,2)==min(A(:,2)));
if min(A(:,2)) == 0
    A(:,2) = A(:,2)+1;
end

max_frame = max(A(:,2));
Timescale = zeros(1,max_frame);
for p = 1:max_frame
    Timescale(p) = p/frame_rate;
end
A_orig = A;

% FIND # PARTICLES, # FRAMES PER PARTICLE, REWRITE 1ST COL WITH PARTICLE #
% % Particle # already in first column
% num_particles = max(A(:,1));
% frames = zeros(1,num_particles); % This one includes empty lines
% actual_frames = zeros(1,num_particles);
% for i = 1:num_particles
%     temp = A(A(:,1)==i,:);
%     frames(i) = length(temp(:,1));
%     actual_frames(i) = frames(i)-sum(isnan(temp(:,3)));
% end

% Don't assume particles are numbered in order (e.g., wouldn't be if
% combine stuck and moving from different files)
l = 1; % Counter for actual # frames of each particle
j = 1; % Counter for # frames of each particle (including empty lines)
k = 0; % Counter for # particles
frames = []; % This one includes empty lines
actual_frames = []; % This one doesn't
for i = 2:length(A(:,1));
    if A(i,1) == A(i-1,1) && A(i,2) == A(i-1,2)+1 % Still same particle
        j = j+1;
        if ~isnan(A(i,3))
            l = l+1;
        end
    else % New particle starts
        A((sum(frames)+1):i-1,1) = k+1; % Assign preceding frames to particle #
        frames = [frames j];
        actual_frames = [actual_frames l];
        k = k+1;
        j = 1;
        l = 1;
    end
    if i == length(A(:,1)) % Last particle
        A((sum(frames)+1):end,1) = k+1; % Assign preceding frames to particle #
        last_particle = A((sum(frames)+1):end,:);
        frames = [frames length(last_particle(:,1))];
        empty_lines = sum(isnan(last_particle(:,3)));
        actual_frames = [actual_frames frames(end)-empty_lines];
        k = k+1;
    end
end
num_particles = k;

% REMOVE PARTICLES WITH <MIN # FRAMES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bad_frames = [];
if min(actual_frames) < min_frames
    for i = 1:num_particles
        k = num_particles-i+1;
        if actual_frames(k) < min_frames
           bad_frames = [bad_frames actual_frames(k)];
           rows = sum(frames(1:k));
           A = [A(1:(rows-frames(k)),:); A((rows+1):end,:)];
        end
    end
    
    if isempty(A) == 1
        num_particles = 0;
        frames = 0;
        actual_frames = 0;
    else
        j = 1;
        temp = A(1,1);
        % Rewrite particle #s with bad particles removed
        for i = 2:length(A(:,1));
            if A(i,1) == temp && A(i,2) == A(i-1,2)+1 % Still same particle
                temp = A(i,1);
                A(i,1) = j;
            else
                j = j+1;
                temp = A(i,1);
                A(i,1) = j;
            end
        end
        A(1,1) = 1; % In case first good particle has number > 1
        num_particles = j;
        frames = zeros(1,num_particles);
        actual_frames = zeros(1,num_particles);
        for i = 1:num_particles;
            temp = A(A(:,1)==i,:);
            frames(i) = length(temp(:,1));
            actual_frames(i) = frames(i)-sum(isnan(temp(:,3)));
        end
    end
end
A_good = A;

% REMOVE PARTICLES LIKELY TO BE DUPLICATES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (MAY ADD CUTOFF VS. PARTICLE DENSITY, ETC.)

% THIS SECTION HAS NOT BEEN UPDATED %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if duplicate_cutoff > 0 && num_particles ~= 0
    % First make matrix with all end and starting frame data
    B = zeros(num_particles,4);
    C = zeros(num_particles,4);
    for i = 1:num_particles
        rows = sum(frames(1:i));
        B(i,:) = A(rows,:);
        if i == 1
            C(i,:) = A(i,:);
        else C(i,:) = A(rows-frames(i)+1,:);
        end
    end
    % Check each particle against every other remaining one
    log_duplicates = [];
    for i = 1:num_particles-1
        for j = 1:(num_particles-i)
            deltat = C(i+j,2)-B(i,2); % Frames diff
            deltax = C(i+j,3)-B(i,3);
            deltay = C(i+j,4)-B(i,4);
            MSD = conversion^2*(deltax^2+deltay^2);
            if MSD < duplicate_cutoff && deltat > 0
                log_duplicates = [log_duplicates; i i+j deltat deltax deltay MSD];
            end
        end
    end
    if isempty(log_duplicates) == 0
        % Determine which particle in duplicate pair has more frames, keep
        [m,n] = size(log_duplicates);
        for i = 1:m
            if frames(log_duplicates(i,1)) < frames(log_duplicates(i,2))
                temp = log_duplicates(i,1);
                log_duplicates(i,1) = log_duplicates(i,2);
                log_duplicates(i,2) = temp;
            end
        end
        % Remove duplicates
        % OLD (WRONG): indices = find(unique(log_duplicates(:,2)));
        [~,indices,~] = unique(log_duplicates(:,2));
        log_duplicates = log_duplicates(indices,:);
        duplicates = sort(log_duplicates(:,2)); % Particle #s to be removed
        for i = 1:length(duplicates)
            k = duplicates(length(duplicates)-i+1);
            rows = sum(frames(1:k));
            A = [A(1:(rows-frames(k)),:); A((rows+1):end,:)];
        end
        % Rewrite particle #s with duplicates removed
        if A(1,1) ~= 1
            A(:,1) = A(:,1)-A(1,1)+1;
        end
        j = 1;
        temp = A(1,1);
        for i = 2:length(A(:,1));
            if A(i,1) == temp && A(i,2) == A(i-1,2)+1 % Still same particle
                temp = A(i,1);
                A(i,1) = j;
            else
                j = j+1;
                temp = A(i,1);
                A(i,1) = j;
            end
        end
        num_particles = j;
        if num_particles == 1 && length(A(find(A(:,1)==1),:)) == 1
            num_particles = 0;
            frames = 0;
        else
            frames = [];
            for i = 1:num_particles;
                frames = [frames length(find(A(:,1)==i))];
            end
        end
    else log_duplicates = {'No duplicates were found.'};
    end
else log_duplicates = {'No duplicate removal was performed.'};
end

% DO VARIOUS CALCULATIONS AND OUTPUT RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XY_stuck = []; XY_moving = [];
if num_particles == 0
    num_stuck = 0; avg_frames_stuck = 0; num_moving = 0; avg_frames_moving = 0;
    summary_header = {'Particles',num_particles,[],[];'Avg Frames',mean(actual_frames),[],[];[],[],[],[];'Bad Particles',length(bad_frames),[],[];'Avg Frames',mean(bad_frames),[],[];[],[],[],[];'Transport Modes:',[],[],[];[],[],'%','Avg Frames';'Active:',[],[],[];'Diffusive:',[],[],[];'Hindered:',[],[],[];'Immobile:',[],[],[];[],[],[],[];'Stuck particles (logMSD<-2)',num_stuck,[],[];'Avg Frames',avg_frames_stuck,[],[];[],[],[],[];'Moving particles (logMSD>=-2)',num_moving,[],[];'Avg Frames',avg_frames_moving,[],[]};
    xlswrite(filename,summary_header,'Summary','A1')
    XY_stuck = zeros(1,4); XY_moving = zeros(1,4); MSD = zeros(min_frames,1);
    xlswrite(filename,XY_stuck,'XY Stuck','A1')
    xlswrite(filename,XY_moving,'XY Moving','A1')
    xlswrite(filename,MSD,'MSD','B2')
else
    [MSD,Def] = calculate_MSD(A,num_particles,frames,Timescale,conversion);
    if min_frames > frame_rate*2
        [modes,avg_frames] = classification(num_particles,frames,MSD,Def);
    else
        modes = zeros(1,4); avg_frames = zeros(1,4);
    end
    % Particles are classified based on Deff at t = 0.2667 s (frame 4 for
    % frame_rate = 15)
    classification_timescale = 4/15; % s
    [~,classification_timescale] = min(abs(Timescale-classification_timescale));
    Deff = Def(classification_timescale,:);
    cutoff = -1.5;
%     if min_frames > 15
%         Deff = Def(frame_rate,:); % frame_rate value corresponds to time scale of 1 s
%         cutoff = -2;
%     else
%         Deff = Def(1,:);
%         cutoff = -1.15; % empirical based on K's F4 120525 HIV data
%     end
    data = log10(Deff);
    data(isnan(data)) = 0;
    data(isinf(data)) = 0;
    [edges,binned,percentages] = dist(data,0.25);
    % Deff_dist "bins" log10(Deff) values at a time scale of 1 s, bin unit
    % 0.25
    
    indices_stuck = find(log10(Deff)<cutoff);
    if isempty(indices_stuck) == 1
        num_stuck = 0;
        avg_frames_stuck = 0;
        XY_stuck = zeros(1,4);
        MSD_stuck = zeros(length(Timescale),1);
    else
        num_stuck = length(indices_stuck);
        avg_frames_stuck = mean(actual_frames(indices_stuck));
        for i = 1:length(indices_stuck)
            XY_stuck = [XY_stuck; A(find(A(:,1)==indices_stuck(i)),:)];
        end
        MSD_stuck = MSD(:,indices_stuck);
    end
    
    indices_moving = find(log10(Deff)>=cutoff);
    if isempty(indices_moving) == 1
        num_moving = 0;
        avg_frames_moving = 0;
        XY_moving = zeros(1,4);
        MSD_moving = zeros(length(Timescale),1);
    else
        num_moving = length(indices_moving);
        avg_frames_moving = mean(actual_frames(indices_moving));
        for i = 1:length(indices_moving)
            XY_moving = [XY_moving; A(A(:,1)==indices_moving(i),:)];
        end
        MSD_moving = MSD(:,indices_moving);
    end
    
    geom_MSD = zeros(1,length(Timescale));
    geom_MSD_stuck = zeros(1,length(Timescale));
    geom_MSD_moving = zeros(1,length(Timescale));
    for i = 1:length(Timescale)
        MSD_row = MSD(i,:);
        MSD_row_stuck = MSD_stuck(i,:);
        MSD_row_moving = MSD_moving(i,:);
        geom_MSD(i) = geomean(nonzeros(MSD_row(~isnan(MSD_row))));
        geom_MSD_stuck(i) = geomean(nonzeros(MSD_row_stuck(~isnan(MSD_row_stuck))));
        geom_MSD_moving(i) = geomean(nonzeros(MSD_row_moving(~isnan(MSD_row_moving))));
    end
    
    geom_Deff = zeros(1,length(Timescale));
    for i = 1:length(Timescale)
        Def_row = Def(i,:);
        geom_Deff(i) = geomean(nonzeros(Def_row(~isnan(Def_row))));
    end
    
    xlswrite(filename,A_orig,'XY Original','A1')
    xlswrite(filename,A_good,'XY Good','A1')
    xlswrite(filename,A,'XY Final','A1')
    xlswrite(filename,XY_stuck,'XY Stuck','A1')
    xlswrite(filename,XY_moving,'XY Moving','A1')
    
    MSD_header = {'Timescale (sec)' 'Geom MSD' '' 'Ind particles -->'};
    MSD_matrix = [Timescale' geom_MSD'];
    MSD_matrix_stuck = [Timescale' geom_MSD_stuck'];
    MSD_matrix_moving = [Timescale' geom_MSD_moving'];
    xlswrite(filename,MSD_header,'MSD','A1')
    xlswrite(filename,MSD_matrix,'MSD','A2')
    xlswrite(filename,MSD,'MSD','D2')
    if isempty(indices_stuck) == 0
        xlswrite(filename,MSD_header,'MSD (Stuck)','A1')
        xlswrite(filename,MSD_matrix_stuck,'MSD (Stuck)','A2')
        xlswrite(filename,MSD_stuck,'MSD (Stuck)','D2')
    end
    if isempty(indices_moving) == 0
        xlswrite(filename,MSD_header,'MSD (Moving)','A1')
        xlswrite(filename,MSD_matrix_moving,'MSD (Moving)','A2')
        xlswrite(filename,MSD_moving,'MSD (Moving)','D2')
    end
    
    log_Timescale = log10(Timescale(1:3*frame_rate))'; % First 3 seconds
    log_geom_MSD = log10(geom_MSD(1:3*frame_rate))';
    p = polyfit(log_Timescale,log_geom_MSD,1);
    alpha_geomean = p(1);
    alpha_individual = zeros(num_particles,1);
    for i = 1:num_particles
        p = polyfit(log_Timescale,log10(MSD(1:3*frame_rate,i)),1);
        alpha_individual(i) = p(1);
    end
    xlswrite(filename,{'Geomean'},'Alpha','A1')
    xlswrite(filename,alpha_geomean,'Alpha','B1')
    xlswrite(filename,{'Individual','Stuck','Moving'},'Alpha','A3')
    xlswrite(filename,alpha_individual,'Alpha','A4')
    if isempty(indices_stuck) == 0
        alpha_stuck = alpha_individual(indices_stuck);
        xlswrite(filename,alpha_stuck,'Alpha','B4')
    end
    if isempty(indices_moving) == 0
        alpha_moving = alpha_individual(indices_moving);
        xlswrite(filename,alpha_moving,'Alpha','C4')
    end
    
    Deff_header = {'Timescale (sec)' 'Geom Deff' '' 'Ind particles -->'};
    Deff_matrix=[Timescale' geom_Deff'];
    xlswrite(filename,Deff_header,'Deff','A1')
    xlswrite(filename,Deff_matrix,'Deff','A2')
    xlswrite(filename,Def,'Deff','D2')
    
    log_Deff_header = {'log10(Deff)' '# Particles' '% Particles'};
    xlswrite(filename,log_Deff_header,'log Deff','A1')
    xlswrite(filename,edges,'log Deff','A2')
    xlswrite(filename,binned,'log Deff','B2')
    xlswrite(filename,percentages,'log Deff','C2')
    
    summary_header = {'Particles',num_particles,[],[];'Avg Frames',mean(actual_frames),[],[];[],[],[],[];'Bad Particles',length(bad_frames),[],[];'Avg Frames',mean(bad_frames),[],[];[],[],[],[];'Transport Modes:',[],[],[];[],[],'%','Avg Frames';'Active:',modes(1),modes(1)/num_particles*100,avg_frames(1);'Diffusive:',modes(2),(modes(2)/num_particles)*100,avg_frames(2);'Hindered:',modes(3),modes(3)/num_particles*100,avg_frames(3);'Immobile:',modes(4),(modes(4)/num_particles)*100,avg_frames(4);[],[],[],[];'Stuck particles (logMSD<-2)',num_stuck,[],[];'Avg Frames',avg_frames_stuck,[],[];[],[],[],[];'Moving particles (logMSD>=-2)',num_moving,[],[];'Avg Frames',avg_frames_moving,[],[]};
    xlswrite(filename,summary_header,'Summary','A1')
    summary_header2 = {'Particle #','Duplicate #','d_frames','d_x','d_y','MSD'};
    xlswrite(filename,summary_header2,'Summary','A20')
    xlswrite(filename,log_duplicates,'Summary','A21')
    [a,b] = size(log_duplicates);
    row = 21+a;
    
    [frames_edges,frames_binned,frames_percentages] = dist(actual_frames,5);
    frames_header = {'# Frames' '# Particles' '% Particles'};
    xlswrite(filename,frames_header,'Summary',['A' num2str(row+1)])
    xlswrite(filename,frames_edges,'Summary',['A' num2str(row+2)])
    xlswrite(filename,frames_binned,'Summary',['B' num2str(row+2)])
    xlswrite(filename,frames_percentages,'Summary',['C' num2str(row+2)])
    
    parameters_header = {'MPT PARAMETERS';[];'Conversion (um/pixel)';'Frame Rate (frames/s)';'Minimum # Frames';'Duplicate Cutoff (MSD; um^2)'};
    xlswrite(filename,parameters_header,'Parameters','A1')
    xlswrite(filename,conversion,'Parameters','B3')
    xlswrite(filename,frame_rate,'Parameters','B4')
    xlswrite(filename,min_frames,'Parameters','B5')
    xlswrite(filename,duplicate_cutoff,'Parameters','B6')
end
DeleteEmptyExcelSheets(filename)


function [MSD,Def] = calculate_MSD(A,num_particles,frames,Timescale,conversion)

MSD = zeros(length(Timescale),num_particles);
Def = zeros(length(Timescale),num_particles);

for j = 1:num_particles
    % Create a temporary matrix containing 1 particle worth of data
    if j == 1
        temp = A(1:frames(1),:);
    else temp = A((1:frames(j))+sum(frames(1:j-1)),:);
    end
    % Calculate MSD for each time scale
    for k=1:frames(j)-1;
        xdisps = temp(1+k:end,3)-temp(1:end-k,3);
        xdisps = xdisps(~isnan(xdisps));
        count = length(xdisps);
        ydisps = temp(1+k:end,4)-temp(1:end-k,4);
        ydisps = ydisps(~isnan(ydisps));
        MSDx=conversion^2*sum((xdisps).^2)/count; %if no NaNs, count =(frames(j)-k); %um^2
        MSDy=conversion^2*sum((ydisps).^2)/count; %um^2
        MSD(k,j)=MSDx+MSDy; %um^2
        Def(k,j) = MSD(k,j)/4./Timescale(k);
    end
end


function [modes,avg_frames] = classification(num_particles,actual_frames,MSD,Def)

class_short = zeros(num_particles,1);
class_long = zeros(num_particles,1);
classify = zeros(num_particles,1);
a = 0; b = 0; c = 0; d = 0;
act_frames = []; diff_frames = []; hind_frames = []; immob_frames = [];

for j = 1:num_particles
    x = Def(15,j)/Def(3,j);
    if x > 1.31238
        class_short(j,1) = 3; % Active
    elseif x < 0.729897
        class_short(j,1) = 1; % Hindered
    else class_short(j,1) = 2; % Diffusive
    end
    y = Def(30,j)/Def(15,j);
    if y > 1.25291
        class_long(j,1) = 3;
    elseif y < 0.725285
        class_long(j,1) = 1;
    else class_long(j,1) = 2;
    end

    if MSD(15,j) > 4E-4;
        if class_short(j) == class_long(j);
            classify(j) = class_short(j);
        elseif class_short(j) == 3;
            classify(j) = 3;
        elseif class_long(j) == 3;
            classify(j) = 3;
        elseif class_short(j) == 1 && class_long(j) == 2
            classify(j) = 1;
        elseif class_short(j) == 2 && class_long(j) == 1
            classify(j) = 1;
        end
    else classify(j) = 0;
    end
    
    if classify(j) == 3;
        a = a+1;
        act_frames = cat(1,act_frames,actual_frames(j));
    elseif classify(j) == 2;
        b = b+1;
        diff_frames = cat(1,diff_frames,actual_frames(j));
    elseif classify(j) == 1;
        c = c+1;
        hind_frames = cat(1,hind_frames,actual_frames(j));
    else d = d+1;
        immob_frames = cat(1,immob_frames,actual_frames(j));
    end
end

avg_frames = [sum(act_frames)/a sum(diff_frames)/b sum(hind_frames)/c sum(immob_frames)/d];
modes = [a b c d];


function [edges,binned,percentages] = dist(data,bin_unit)

limit_upper = max(data);
limit_lower = min(data);
range = ceil(abs(limit_upper-limit_lower));
num_bins = ceil(range/bin_unit);
lower_start = floor(limit_lower/bin_unit)*bin_unit;

edges = zeros(num_bins+1,1);
for i = 1:num_bins+1
    edges(i) = lower_start+(i-1)*bin_unit;
end

binned = histc(nonzeros(data),edges);
percentages = binned/sum(binned)*100;