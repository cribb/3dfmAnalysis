function v = zerodaq(signal, DAQid)

if nargin < 2 || isempty(DAQid)
    logentry('No DAQ board defined. You must define a DAQ board.  Exiting now...');
    return;
end;

    DAQ_sampling_rate = 1000;
	nDACout = 8;
	Nrepeat = 0;       
	Vrange = [-10 10];
    channels = [0:length(signal)-1];
    
    if length(signal) < 1
        signal = zeros(1, nDACout);
		channels = [0:nDACout-1]';
	end

    DACoperator(signal, Nrepeat, DAQid, channels, DAQ_sampling_rate, Vrange);

    return;
    
    
%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'zerodaq: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
