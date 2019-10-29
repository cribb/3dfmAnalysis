function reply_final = ba_magfield_sandbox
% BA_MAGFIELD_SANDBOX receives header info for the gauss-meter (test function)
%

% % Instrument Connection

% Codes
BUFF          = repmat(hex2dec('00'), 1, 5);
ID_METER_PROP = [hex2dec('01') BUFF];
STREAM_DATA   = [hex2dec('03') BUFF];
RESET_TIME    = [hex2dec('04') BUFF];
ACK           = [hex2dec('08') BUFF];
BURST_DATA    = [hex2dec('22') BUFF];
RESET_ZERO    = [hex2dec('1B') BUFF];


% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM3');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);

% Configure instrument object, obj1.
set(obj1, 'BaudRate', 115200);

% Communicating with instrument object, obj1.
fwrite(obj1, ID_METER_PROP, 'uint8');
reply{1,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{2,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{3,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{4,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{5,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{6,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{7,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{8,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{9,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{10,1} = fscanf(obj1, '%c', 21);
fwrite(obj1, ACK, 'uint8');
reply{11,1} = fscanf(obj1, '%c', 21);

reply_trimmed = cellfun(@(x1)(x1(1:end-1)), reply, 'UniformOutput', false);
reply_globbed = strcat(reply_trimmed{:});
reply_split = reshape(strsplit(reply_globbed, ':'), [], 1);
reply_split = reply_split(:);
reply_final = reply_split(2:end-1);


