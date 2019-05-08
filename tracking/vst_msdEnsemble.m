function outs = vst_msdEnsemble(DataIn)

    % Identifying the trajectory groups

    msdData = DataIn.MsdTable;

    [g, msdEnsemble] = findgroups(msdData(:,{'Fid', 'Tau', 'Tau_s'}));
    
%      msdEnsemble.FileSummary.Tmp  = [];
%     smallT = msdData(:,{'MsdX','MsdY','MsdXo','MsdYo'});
    groupingVars = {'Fid', 'Tau'};
    dataVars = {'MsdX', 'MsdY', 'MsdXo', 'MsdYo'};
    interestingStats = {'mean', 'median', 'sem', 'numel'};
%     tmp = grpstats(msdData, groupingVars, interestingStats, 'DataVars', dataVars);
%     for k = 1:length(dataVars)
%         tmpmystats{:,k} = splitapply(@(x1,x2){gmsdstats(x1,x2)}, msdData(:,dataVars(k)), ...
%                                                           msdData.N, g);
%     end

    ml_msdX  = cell2mat(splitapply(@(x1,x2){gmsdstats(x1,x2)}, msdData.MsdX,  msdData.N, g));
    ml_msdY  = cell2mat(splitapply(@(x1,x2){gmsdstats(x1,x2)}, msdData.MsdY,  msdData.N, g));
    ml_msdXo = cell2mat(splitapply(@(x1,x2){gmsdstats(x1,x2)}, msdData.MsdXo, msdData.N, g));
    ml_msdYo = cell2mat(splitapply(@(x1,x2){gmsdstats(x1,x2)}, msdData.MsdYo, msdData.N, g));

    msdEnsemble.logmsdX  = ml_msdX(:,1);
    msdEnsemble.errmsdX  = ml_msdX(:,2);

    msdEnsemble.logmsdXo = ml_msdY(:,1);
    msdEnsemble.errmsdXo = ml_msdY(:,2);

    msdEnsemble.logmsdY  = ml_msdXo(:,1);
    msdEnsemble.errmsdY  = ml_msdXo(:,2);

    msdEnsemble.logmsdYo = ml_msdYo(:,1);
    msdEnsemble.errmsdYo = ml_msdYo(:,2);

    outs = msdEnsemble;

return

function outs = gmsdstats(mymsd, n)

    N = length(n);

    weights = n ./ sum(n);


    logmsd = log10(mymsd);
    mean_logmsd = nansum(weights .* logmsd);

    % computing error for logmsd
    Vishmat = nansum(weights .* (repmat(mean_logmsd, N, 1) - logmsd).^2);
    msderr =  sqrt(Vishmat ./ N);

    outs = [mean_logmsd , msderr];

return