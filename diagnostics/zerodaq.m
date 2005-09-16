function v = zerodaq(signal)
	DAQ_sampling_rate = 1000;
	nDACout = 8;
	Nrepeat = 0;
	DAQid = 'PCI-6733';
	Vrange = [-10 10];
    channels = [0:length(signal)-1];
    
    if length(signal) < 1
        signal = zeros(1, nDACout);
		channels = [0:nDACout-1]';
	end

    DACoperator(signal, Nrepeat, DAQid, channels, DAQ_sampling_rate, Vrange);
    
    
