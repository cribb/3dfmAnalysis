function [num_frames] = mat_recolumn(basepath,basefile,FOVs)

% Input
    % basepath: basepath: path to the root folder of the experiment (should end in
    %           '\'
    % basefile: filename containing matrix up to the number, assuming form
    %   [basefile ## .raw.vrpn.evt.mat]
        % Matrix contained in basefile has columns:
        % [--, bead#, frame#, x (microm), y (microm)]
        % Matrix = tracking.spot3DSecUsecIndexFramenumXYZRPY
    % FOVs: vector of numbers to be processed (1 will be 01, 2 -> 02)
% Output
    % Matrices reordered with column titles:
        % [x (microm), y (microm), frame#, bead#]
    % written to the folder [basepath 'Bead_Tracking\res_fileds\ddposum_files']
    
    
mkdir(basepath,'Bead_Tracking\ddposum_files')
    num_frames = zeros(size(FOVs));
for j = FOVs
    j = num2str(j);
    if size(j) == 1
        j = ['0' j];
    end
    A = open([basepath basefile j '.raw.vrpn.evt.mat']);
    tempMat = A.tracking.spot3DSecUsecIndexFramenumXYZRPY;
    ddposum = zeros(size(tempMat,1),4);
    ddposum(:,1) = tempMat(:,4);
    ddposum(:,2) = tempMat(:,5);
    ddposum(:,3) = tempMat(:,3);
    ddposum(:,4) = tempMat(:,2);
    num_frames(j) = max(tempMat(:,3));
    save([basepath 'Bead_Tracking\ddposum_files\' 'ddposum_run' j '.mat'],'ddposum')
end

num_frames = min(num_frames);