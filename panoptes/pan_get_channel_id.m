function channelid = pan_get_channel_id(wellid)
% PAN_GET_CHANNEL_ID Extracts the optical channel used to measure the bead trajectories

N = size(wellid);

channelid = NaN(N);

for k = 1:prod(N)
    switch wellid(k)
        case {1,2,13,14,25,26,37,38}
            channelid(k) = 1;
        case {3,4,15,16,27,28,39,40}
            channelid(k) = 2;
        case {5,6,17,18,29,30,41,42}
            channelid(k) = 3;
        case {7,8,19,20,31,32,43,44}
            channelid(k) = 4;
        case {9,10,21,22,33,34,45,46}
            channelid(k) = 5;
        case {11,12,23,24,35,36,47,48}
            channelid(k) = 6;
        case {49,50,61,62,73,74,85,86}
            channelid(k) = 7;
        case {51,52,63,64,75,76,87,88}
            channelid(k) = 8;
        case {53,54,65,66,77,78,89,90}
            channelid(k) = 9;
        case {55,56,67,68,79,80,91,92}
            channelid(k) = 10;
        case {57,58,69,70,81,82,93,94}
            channelid(k) = 11;
        case {59,60,71,72,83,84,95,96}
            channelid(k) = 12;
        otherwise
            channelid(k) = NaN;
    end
end

return;