function MSD = time_MSD(data, sim_or_exp)
%different than MSD(tau)--there is no time-averaging, this only employs path
%averaging, using all of the paths in the input "data" to produce a single
%MSD value for each time step.

if strcmp('exp', sim_or_exp)
    %only takes as input data whose paths all have the same length
    path_length = max([data.PathLength]);
    bool = [data.PathLength] < path_length;
    data(bool) = [];
    MSD = zeros(path_length, 2);
    path_num = length(data);
    path_data = zeros(path_length, path_num*2);
    for i = 1:path_num
        path_data(1:path_length, (i-1)*2+1:i*2) = [data(i).Positions];
    end
    for i = 2:path_length
        disp = path_data(i,:) - path_data(1,:);
        squaredsum_disp = disp(1:2:end).^2 + disp(2:2:end).^2;
        MSD(i,1) = mean(squaredsum_disp);
        MSD(i,2) = std(squaredsum_disp);
    end
    
elseif strcmp('sim', sim_or_exp)
    path_length = size(data.X, 1);
    MSD = zeros(path_length, 2);
    path_num = size(data.X, 2);
    path_data = zeros(path_length, path_num*2);
    for i = 1:path_num
        path_data(1:path_length, (i-1)*2+1:i*2) = [data.X(i,:) data.Y(i,:)];
    end
    for i = 2:path_length
        disp = path_data(i,:) - path_data(1,:);
        squaredsum_disp = disp(1:2:end).^2 + disp(2:2:end).^2;
        MSD(i,1) = mean(squaredsum_disp);
        MSD(i,2) = std(squaredsum_disp);
    end
end



        
    