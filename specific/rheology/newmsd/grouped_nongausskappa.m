function outs = grouped_nongausskappa(DataIn, group_names)
% Grouped Step-size Distributions
% DataIn = hbe3pct;

    if nargin < 2 || isempty(group_names)
        group_names = {'SampleName', 'SampleInstance', 'FovID', 'Tau'};
    end


    v = DataIn.VidTable(:,{'Fid', 'SampleName', 'SampleInstance', 'FovID', 'Fps', 'Calibum'});
    m = DataIn.MsdTable;

    b = join(m, v);

    % Clear out rows that contain no viable numerical data (empty MSDs, etc)
    b(b.N == 0, :) = [];

    [g, foo] = findgroups(b(:,group_names));

    ssd_kappa = splitapply(@nongausskappa, [b.Xdiff, b.Ydiff, b.Xodiff, b.Yodiff], g);
                 
        outs = foo;
        outs.Xkappa = ssd_kappa(:,1);
        outs.Ykappa = ssd_kappa(:,2);
        outs.Xokappa = ssd_kappa(:,3);
        outs.Yokappa = ssd_kappa(:,4);
        outs.N = ssd_kappa(:,5);
return

function outs = nongausskappa(data)
    data = cell2mat(data);
    N = sum(isfinite(data(:,1)));
    outs = [kurtosis(data, [], 1)/3 - 1, N];
return

