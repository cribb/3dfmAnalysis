function varargout = DACoperator(inputs, Nrepeat, board, channels, srate, Vrange)
% 3DFM function  
% GUI Analysis 
% last modified 05/18/04 
%
% data = DACoperator(inputs, duration, board, channels, srate);  
% This function is mainly usedSends the input vector to specified channles on specified AO board. 
% This function is mainly used as the back-end of custom signal generator UI.  
% where 
% inputs : M X N matrix containing M input samples for each of the N channels
%           All inputs are in units of Volts.
% Nrepeat: No of times we should repeat the input vector [defaulted to 1]
% board: DAC board number [defaulted to 'PCI-6733']
% channles: 1 X N vector containing channel indices [defaulted to 0:N-1]
% srate: Sample rate that the board should operate on [defaulted to 10000]
% Vrange: 1 X 2 matrix for Voltage range setting for ALL channels on the specified board
%           defaulted to [-10 10]
% Created : 05/02/04
if (nargin < 1 | isempty(inputs)) error('DACoperator: Input matrix is empty or not provided');
else [M N] = size(inputs);
end
if (nargin < 2 | isempty(Nrepeat))  Nrepeat = 1;          
end;
if (nargin < 3 | isempty(board))  board = 'PCI-6733';             
    warning('DACoperator: Using default AO board: PCI-6733 (stage-controller)...');   
end;
if (nargin < 4 | isempty(channles))   channels = 0:length;
    warning(['DACoperator: Using default AO channles: 0 to ,',num2str(N-1)];
end;
if (nargin < 5 | isempty(srate))   srate  = 10000;	
    disp(['DACoperator: Sampling rate defaulted to ',num2str(srate),'Hz']);
end;
if (nargin < 6 | isempty(Vrange))   Vrange = [-10 10];	
    disp(['DACoperator: Voltage range defaulted as ',num2str(Vrange(1)),' to ', num2str(Vrange(2)),' volts']);
end;

%----check validity of arguements
if (N ~= length(channels))
    error('DACoperator: No of columns in input matrix does not match with no of channels');
end
% find the board id that goes with the name
hwinfo = daqhwinfo('nidaq');
AOid = -1;
for i=1:length(hwinfo.BoardNames)
  if strcmp(char(hwinfo.BoardNames(i)), AOname)
    AOid = i;
  end
end
if AOid < 0;  error('DACoperator: output board not found');  end
daqreset; %stop if the transfer is already in progress and clear old AO objects
% setup the output
AO = analogoutput('nidaq', AOid);
Ochan = addchannel(AO, channels); 
set(Ochan, 'OutputRange', Vrange);  
set(AO, 'SampleRate', srate);
set(AO, 'RepeatOutput', Nrepeat);
%clipping the data so that its within specified bounds of the board
posData = min(posData,Vrange(1,1)); 
posData = max(posData,Vrange(1,2));

putdata(AO, posData); % enqueue the data
start(AO); % send the data

