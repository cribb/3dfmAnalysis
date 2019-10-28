function ba_plot_forcehist(ba_process_data, aggregating_variables, plotorder)

    Data = ba_process_data;
    aggVars = aggregating_variables(:);

    if ~iscell(aggVars)
        error('Need cell array of aggregating variables');
    end
    % {'BeadChemistry', 'Media'}
    [g, BeadCountTable] = findgroups(Data.FileTable(:,aggVars));
    BeadCountTable.TotalBeads = splitapply(@sum, Data.FileTable.FirstCount, g);

    FileVars(1,:) = [{'Fid'}; aggVars];
    FTable = join(Data.ForceTable, Data.FileTable(:,FileVars));
    FTable = innerjoin(FTable, BeadCountTable, 'Keys', aggVars);
    FTable(FTable.Force <= 0,:) = [];

    [gF, grpF] = findgroups(FTable(:,aggVars));
    
    for k = 1:length(aggVars)
    end
    
    ystrings = string(grpF.BeadChemistry) + '_' + string(grpF.SubstrateLotNumber);
%     ystrings = string(grpF.BeadChemistry) + '_' + string(grpF.Media);
    
    maxforce = 90e-9;

    grpF.Force = splitapply(@(x1,x2){sa_attach_stuck_beads(x1,x2,maxforce)}, FTable.Force, ...
                                                                       FTable.TotalBeads, ...
                                                                       gF);

    if nargin < 3 || isempty(plotorder)
        plotorder(:,1) = [2 1 4 3 6 5];
    end
    Nplots = length(plotorder);

    [gT, grpT] = findgroups(grpF(:,aggVars));
    h = figure; 
    h.Units = 'normalized';
    figheight = 1-exp(-Nplots/4);
%     h.Position = [0.35 0.06 0.3 (Nplots*0.3)^1];
    h.Position = [0.35 0.06 0.3 figheight];
    ax = splitapply(@(x1,x2,x3)mysubplot(x1,x2,x3,Nplots), grpF.Force, ystrings(:), plotorder(:), gT);
end

function myforce = sa_attach_stuck_beads(force, beadcount, maxforce)
    padforce = beadcount(1) - length(force);
    myforce = [force(:) ; repmat(maxforce,padforce,1)];
end

function h = mysubplot(force, condition_label, subplotn, subplotN)

    subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.1 0.01], [0.1 0.01]);

    logforce = log10(force{1}*1e9);
    
    h = subplot(subplotN,1,subplotn);     
    ax1 = histogram(logforce, 24, 'Normalization', 'probability');
    
    if subplotn ~= subplotN
        h.XTickLabels = [];
    end
    
%     h.YTick = [0:0.2:1]; %#ok<NBRAK>
    h.XLim = [-4 2]; 
    h.YLim = [0 1];
    
    grid on;
    
    if subplotn == 1
        h.YTick = [0:0.2:1];        
    else
        h.YTick = [0:0.2:0.8];
    end
    
    if subplotn == subplotN
        xlabel('log_{10}(Force) [nN]'); 
    end
    ylabel(condition_label, 'Interpreter', 'none');
end

