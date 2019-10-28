function ba_plot_fracleft(ba_process_data, aggregating_variables)

Data = ba_process_data;

% "Fraction Left" plot is always going to be plotting the Fraction of beads
% left to detach vs the force at which they detach. SO, that means all we
% need are the aggregating variables AND those relevant columns
ForceTableVars = {'Fid', 'Force', 'FractionLeft'};
FileTableVars = [{'Fid'}, aggregating_variables(:)'];
% FileTableVars = {'Fid', aggregating_variables{:}};

RelevantData = innerjoin(Data.ForceTable(:,ForceTableVars), ...
                         Data.FileTable(:, FileTableVars), ...
                         'Keys', 'Fid');

[g, grpF] = findgroups(RelevantData(:,aggregating_variables));
grpFstr = string(table2array(grpF));
ystrings = join(grpFstr, '_');


f = figure;
gscatter(RelevantData.Force*1e9, RelevantData.FractionLeft, g);
legend(ystrings, 'Interpreter', 'none');
xlabel('Force [nN]');
ylabel('FractionLeft');

ax = gca;
ax.XScale = 'log';
ax.YScale = 'linear';

end


function outs = sa_sortforce(forceANDfractionleft, direction)

    if nargin < 2 || isempty(direction)
        direction = 'ascend';
    end

    [outs,Fidx] = sortrows(forceANDfractionleft, direction);

end