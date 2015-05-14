function [ MSD_beadSize_struct ] = pan_cmp_MSD_beadSize( bayes_model_output, RMS_struct )

MSD_IF1 = NaN;
MSD_IC1 = NaN;
MSD_IP1 = NaN;
MSD_SF1 = NaN;
MSD_SC1 = NaN;
MSD_SP1 = NaN;

MSD_IF2 = NaN;
MSD_IC2 = NaN;
MSD_IP2 = NaN;
MSD_SF2 = NaN;
MSD_SC2 = NaN;
MSD_SP2 = NaN;

for k = 1:length(bayes_model_output)
    
    if strcmp(RMS_struct(k,1).name, 'IF1')
        MSD_IF1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'IF2')
        MSD_IF2 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'IC1')
        MSD_IC1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'IC2')
        MSD_IC2 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'IP1')
        MSD_IP1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'IP2')
        MSD_IP2 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SF1')
        MSD_SF1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SF2')
        MSD_SF2 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SC1')
        MSD_SC1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SC2')
        MSD_SC2 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SP1')
        MSD_SP1 = RMS_struct(k,1).MSD_DA;
    end
    if strcmp(RMS_struct(k,1).name, 'SP2')
        MSD_SP2 = RMS_struct(k,1).MSD_DA;
    end
    
end

IF1_OVER_IF2 = MSD_IF1 / MSD_IF2;
IC1_OVER_IC2 = MSD_IC1 / MSD_IC2;
IP1_OVER_IP2 = MSD_IP1 / MSD_IP2;

SF1_OVER_SF2 = MSD_SF1 / MSD_SF2;
SC1_OVER_SC2 = MSD_SC1 / MSD_SC2;
SP1_OVER_SP2 = MSD_SP1 / MSD_SP2;

MSD_beadSize_struct = struct;
%a = 'IF1/IF2';
%b = 'SF1/SF2';
MSD_beadSize_struct(1).labels = 'IF1/IF2';
MSD_beadSize_struct(2).labels = 'IC1/IC2';
MSD_beadSize_struct(3).labels = 'IP1/IP2';
MSD_beadSize_struct(4).labels = 'SF1/SF2';
MSD_beadSize_struct(5).labels = 'SC1/SC2';
MSD_beadSize_struct(6).labels = 'SP1/SP2';

MSD_beadSize_struct(1).values = IF1_OVER_IF2;
MSD_beadSize_struct(2).values = IC1_OVER_IC2;
MSD_beadSize_struct(3).values = IP1_OVER_IP2;
MSD_beadSize_struct(4).values = SF1_OVER_SF2;
MSD_beadSize_struct(5).values = SC1_OVER_SC2;
MSD_beadSize_struct(6).values = SP1_OVER_SP2;


end

