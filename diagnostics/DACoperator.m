function varargout = DACoperator(inputs, Nrepeat, board, channels, srate, Vrange)
% 3DFM function  
% DSP / DAQ 
% last modified 12/18/04 
%
% data = DACoperator(inputs, duration, board, channels, srate);  
%
% This function sends the input vector to specified channels on specified AO board. 
% This function is mainly used as the back-end of custom signal generator UI.  
% where 
% inputs : M X N matrix containing M input samples for each of the N channels
%           All inputs are in units of Volts.
% Nrepeat: No of times to repeat the input vector [defaulted to 1]
% board: DAC board number [defaulted to 'PCI-6733'], or 'daqtest' for
%        signal testing on non-DAq containing PCs.
% channels: 1 X N vector containing channel indices [defaulted to 0:N-1]
% srate: Sample rate that the board should operate on [defaulted to 10000]
% Vrange: 1 X 2 matrix for Voltage range setting for ALL channels on the specified board
%           defaulted to [-10 10]
% Created : 05/02/04
%

%----check validity of arguments
if (nargin < 1 | isempty(inputs)) 
    error('DACoperator: Input matrix is empty or not provided');
else 
    [M N] = size(inputs);
end

if (nargin < 2 | isempty(Nrepeat))  
    Nrepeat = 1;          
end;

if (nargin < 3 | isempty(board))  
    board = 'PCI-6733';             
    warning('DACoperator: Using default AO board: PCI-6733 (stage-controller)...');   
end;

if (nargin < 4 | isempty(channels))   
    channels = 0:length;
    warning(['DACoperator: Using default AO channels: 0 to ,',num2str(N-1)]);
end;

if (nargin < 5 | isempty(srate))   
    srate  = 10000;	
    disp(['DACoperator: Sampling rate defaulted to ',num2str(srate),'Hz']);
end;

if (nargin < 6 | isempty(Vrange))   
    Vrange = [-10 10];	
    disp(['DACoperator: Voltage range defaulted as ',num2str(Vrange(1)),' to ', num2str(Vrange(2)),' volts']);
end;

if (N ~= length(channels))
    error('DACoperator: No of columns in input matrix does not match with no of channels');
end


% find the board id that goes with the name
if ~strcmp(board,'daqtest')
	hwinfo = daqhwinfo('nidaq');
	AOid = -1;
	for i=1:length(hwinfo.BoardNames)
      if strcmp(char(hwinfo.BoardNames(i)), board)
        AOid = i;
      end
	end
else
    AOid = -1;
end

% condition inputs to DAC board
% clip the data so that its within specified bounds of the board
inputs = max(inputs,Vrange(1,1)); 
inputs = min(inputs,Vrange(1,2));


% output information to "virtual daq board" to convey what *would* have
% gone to DAQout had a real board been specified in the function call.
if (AOid < 0) | strcmp(board,'daqtest');  
    warning(['DACoperator: output board not found or board == daqtest.  '  ...
             'Plotting DACout instead of sending to DAq board.']);  
    daqreset;
    
    t = [0:1/srate:(length(inputs)-1)/srate];
    
    figure;
    plot(t, inputs);
    axis([0 t(end) Vrange(1) Vrange(2)]);    
    title('DAQtest Output');
    xlabel('time (s)');
    ylabel('Voltage (V)');
    
    fprintf('\n Board ID: %s', board);
    fprintf('\n Sampling Rate: %i', srate);
    fprintf('\n Voltage Range: [%d %d]', Vrange(1), Vrange(2));
    fprintf('\n Number of repeats: %d', Nrepeat);
    fprintf('\n Writing to output channels: %i', channels);
    fprintf('\n Signals to send to DAq channels are plotted.');
    
    return;
end

% stop if the transfer is already in progress and clear old AO objects
daqreset; 

% setup the output
AO = analogoutput('nidaq', AOid);
Ochan = addchannel(AO, channels); 
set(Ochan, 'OutputRange', Vrange);  
set(AO, 'SampleRate', srate);
set(AO, 'RepeatOutput', Nrepeat);


putdata(AO, inputs); % enqueue the data
start(AO); % send the data

