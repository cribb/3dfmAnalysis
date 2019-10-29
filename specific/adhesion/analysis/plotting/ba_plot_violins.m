function ba_plot_violins(ba_process_data, aggregating_variables, plotorder)

Data = ba_process_data;
aggVars = aggregating_variables(:);

% "Fraction Left" plot is always going to be plotting the Fraction of beads
% left to detach vs the force at which they detach. SO, that means all we
% need are the aggregating variables AND those relevant columns
ForceTableVars = {'Fid', 'Force'};
FileTableVars = [{'Fid'}, aggregating_variables(:)'];
% FileTableVars = {'Fid', aggregating_variables{:}};

RelevantData = innerjoin(Data.ForceTable(:,ForceTableVars), ...
                         Data.FileTable(:, FileTableVars), ...
                         'Keys', 'Fid');

[g, grpF] = findgroups(RelevantData(:,aggregating_variables));
grpFstr = string(table2array(grpF));
ystrings = join(grpFstr, '_');

AllForces = RelevantData.Force;
AllForces(AllForces < 0) = NaN;

N = splitapply(@numel, AllForces, g);


ForceMatrix = NaN(max(N), numel(unique(g)));

for k = 1:numel(unique(g))
    Forces = AllForces( g == k);
    ForceMatrix(1:length(Forces),k) = Forces(:);
end

% ForceMatrix = log10(ForceMatrix);

h = figure; 
violin(ForceMatrix, 'facecolor', [1 1 0.52], 'mc', '', 'medc', '');

figure(h);
hold on;
boxplot(ForceMatrix, 'Notch', 'on', 'Labels', ystrings);
grid;

% [gMean, gSEM, gStd, gVar, gMeanCI] = grpstats(RelevantData.Force, g, {'mean', 'sem', 'std', 'var', 'meanci'});

% gCov = gStd ./ gMean;
% 
% T = table(N, gMean, gStd, gCov, gSEM, gVar, gMeanCI, 'VariableNames', ...
%         {'N', 'Mean', 'StDev', 'COV', 'StdErr', 'Var', 'MeanCI'});
% T = [grpF T];

return