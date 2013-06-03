load chromosomes.mat

% Choose the set of models to test with MSD-Bayes
msd_params.models = {'D','V','DV'};

% Create a results cell array to store the results of the MSD-Bayes
% analysis for each grouping of the chromosomes
results = cell(1,3);

% Create arrays to store the model probabilities for each grouping
D_probabilities = cell(1,3);
V_probabilities = cell(1,3);
DV_probabilities = cell(1,3);

% For each grouping of the chromosomes
for i=1:3
    
    % Create a cell array to store the results for each group within this
    % grouping
    results{i} = cell(1,length(groups{i}));
    
    % For each group within this grouping
    for g=1:length(groups{i})
        
        % Select the appropriate chromosome MSD curves that are in the
        % group, using the listed column indices
        MSD_curves = MSD_curves_chromosomes(:,groups{i}{g});
        
        % Run MSD-Bayes to perform Bayesian inference
        results{i}{g} = msd_curves_bayes(timelags, MSD_curves, msd_params);
        
        % Store the model probabilities
        D_probabilities{i}(g) = results{i}{g}.mean_curve.D.PrM;
        V_probabilities{i}(g) = results{i}{g}.mean_curve.V.PrM;
        DV_probabilities{i}(g) = results{i}{g}.mean_curve.DV.PrM;
        
    end
    
end



figure('Position',[100 100 600 700])
for i=1:3
    subplot(3,1,i)
    stack = [D_probabilities{i}; V_probabilities{i}; DV_probabilities{i}]';
    bar(stack,0.1*size(stack,1),'stack');
    set(gcf,'Color','w')
    set(gca,'FontSize',18)
    set(findobj('Type','line'),'LineWidth',2)
    set(gca,'box','on')
    colormap([0 158 115; 204 121 167; 0 114 178]/256)
    ylim([0 1])
    ylabel('Model probability')
    xlabel({'Group'; '(ordered by initial distance from AP)'})
    legend('D','V','DV','Location','NorthEastOutside')
    legend boxoff
end

