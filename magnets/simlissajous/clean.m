function cleaned = clean(magnets)
%extract out the overlaping excitations
if(~isfield(magnets,'sectime'))
    magnets.sectime = magnets.time(:,1) + magnets.time(:,2)*1e-6;
end
cleaned.sectime(1,1) = magnets.sectime(1,1);
if(isfield(magnets,'joints'))
    cleaned.joints = magnets.joints;
end
if(isfield(magnets,'info'))
    cleaned.info = info;
end
s = size(magnets.analogs);
Nchannels = s(1,2);
j = 1;
k = 1;
for (j = Nchannels:Nchannels:s(1,1))
    cleaned.sectime(k,1) = magnets.sectime(j,1);
    cleaned.analogs(k,1:Nchannels) = magnets.analogs(j,:);
    k = k+1;
end    

%---------- a less reliable approach for cleaning--
% % for hexapole magnets we have facility of using high frequencies
% % so in cleaning the data set we need to know what frequency the data was
% % sampled at - to determine the length of window.
% dt = diff(magnets.sectime);
% % we know the program logs change in one coil at a time, while keeping all
% % other coils same - this introduces another sampling rate which is always
% % higher than 200 Hz. Clean those pseudo data points first before taking
% % mean
% iunder = find(dt < 0.005);
% dt(iunder) = 0;
% dt = nonzeros(dt); 
% meandt = mean(dt); % mean length of the jumping window
% WIN = meandt/2; % applied factor of two just to be safe
% 
% cleaned.analogs(1,:) = magnets.analogs(1,:);
% last_time = cleaned.sectime(1,1);
% k = 1;
% j = 1;
% s = size(magnets.analogs);
% Nchannels = s(1,2);
% dt = diff(magnets.sectime);
% 
% while(j < s(1,1))
%     
%     k = k+1;
%     i = min(find(magnets.sectime - last_time > WIN));
%     
%     if(isempty(i))
%         break;
%     end
%     j = i+Nchannels-1;
%     last_time = magnets.sectime(j,1);
%     cleaned.sectime(k,1) = last_time;
%     cleaned.analogs(k,:) = magnets.analogs(j,:);    
% end
% 
% % test if the cleaning was performed correctly
