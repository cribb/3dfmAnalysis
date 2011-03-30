function v = DACoperator(inputs, Nrepeat, board, channels, srate, Vrange)
% DACOPERATOR Sends input vector to specified channels on specified AO board
%
% 3DFM function  
% DSP / DAQ 
% last modified 11/14/08 (krisford)
%
% data = DACoperator(inputs, Nrepeat, board, channels, srate, Vrange);  
%
% This function sends the input vector to specified channels on specified AO board. 
% This function is mainly used as the back-end of custom signal generator UI.  
% where 
% inputs : M X N matrix containing M input samples for each of the N channels
%           All inputs are in units of Volts.
% Nrepeat: No of times to repeat the input vector [defaulted to 0]
% board: DAC board number or 'daqtest' (default) for
%        signal testing on PCs that don't have DAC board
% channels: 1 X N vector containing channel indices [defaulted to 0:N-1]
% srate: Sample rate that the board should operate on [defaulted to 10000]
% Vrange: 1 X 2 matrix for Voltage range setting for ALL channels on the specified board
%           defaulted to [-10 10]


%----check validity of arguments
if (nargin < 1 | isempty(inputs)) 
    error('DACoperator: Input matrix is empty or not provided');
else 
    [M N] = size(inputs);
end

if (nargin < 2 | isempty(Nrepeat))  
    Nrepeat = 0;          
end;

if (nargin < 3 | isempty(board))  
    board = 'daqtest';             
    logentry('No board specified.  Using virtual board "daqtest" as default');   
end;

if (nargin < 4 | isempty(channels))   
    channels = 0:length;
    logentry(['DACoperator: Using default AO channels: 0 to ,',num2str(N-1)]);
end;

if (nargin < 5 | isempty(srate))   
    srate  = 10000;	
    logentry(['Sampling rate defaulted to ',num2str(srate),'Hz']);
end;

if (nargin < 6 | isempty(Vrange))   
    Vrange = [-10 10];	
    logentry(['DACoperator: Voltage range defaulted as ',num2str(Vrange(1)),' to ', num2str(Vrange(2)),' volts']);
end;

if (N ~= length(channels))
    error('DACoperator: No of columns in input matrix does not match with no of channels');
end


% find the board id that goes with the name
if ~strcmp(board,'daqtest')
    try
        hwinfo = daqhwinfo('nidaq');
    catch
        board = 'daqtest';
        logentry('No NI DAq boards found.  Defaulting to "daqtest" virtual board.');
    end
end

if ~strcmp(board,'daqtest')
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
    logentry(['output board not found or board == daqtest.'...
             '  Plotting DACout instead of sending to DAq board.']);  

    t = [0:1/srate:(length(inputs)*(Nrepeat+1) - 1)/srate]';
    
    try
        fullinput = repmat(inputs, Nrepeat+1, 1);
    catch
        logentry('Input is too long.  Shorten the experiment duration or the sampling rate.');
        v = 0;
        beep;
        return;
    end
    start_time = date2unixsecs;
    
    logentry(['Board ID: ' board]);
    logentry(['Sampling Rate: ' num2str(srate)]);
    logentry(['Voltage Range: [' num2str(Vrange(1)) ' ' num2str(Vrange(2)) ']']);
    logentry(['Number of repeats: ' num2str(Nrepeat) ] );
    logentry(['Writing to output channels: ' num2str(channels(:)') ]);
    logentry(['Start time would have been: ' num2str((start_time))]);
    logentry(['Signals to send to DAq channels are plotted.']);

    % set up decimation of signal for quicker plotting.
    if length(t) > 10000000
        t_p = t(1:10000:end);
        fullinput_p = fullinput(1:10000:end,:);
        logentry('Plotting vector is decimated 1:10000');                
    elseif length(t) > 1000000
        t_p = t(1:1000:end);
        fullinput_p = fullinput(1:1000:end,:);
        logentry('Plotting vector is decimated 1:1000');        
    elseif length(t) > 100000
        t_p = t(1:100:end);
        fullinput_p = fullinput(1:100:end,:);        
        logentry('Plotting vector is decimated 1:100');
    elseif length(t) > 10000
        t_p = t(1:10:end);
        fullinput_p = fullinput(1:10:end,:);
        logentry('Plotting vector is decimated 1:10');
    else
        t_p = t;
        fullinput_p = fullinput;
    end
    
    figure;
    plot(t_p, fullinput_p);
    axis([0 t(end) Vrange(1) Vrange(2)]);    
    title('DAQtest Output');
    xlabel('time (s)');
    ylabel('Voltage (V)');
    pretty_plot;
    
    v = start_time;    
    daqreset;
   
    return;
end

% stop if the transfer is already in progress and clear old AO objects
daqreset; 

% setup the output
AO = analogoutput('nidaq', ['Dev' num2str(AOid)]);
Ochan = addchannel(AO, channels); 
set(Ochan, 'OutputRange', Vrange);  
set(AO, 'SampleRate', srate);
set(AO, 'RepeatOutput', Nrepeat);


putdata(AO, inputs); % enqueue the data
v = date2unixsecs;
start(AO); % send the data

return;


% ----------------
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'DACoperator: '];
     
     fprintf('%s%s\n', headertext, txt);

