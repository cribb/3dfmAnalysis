% Note: This example may take a few minutes to run


load simulations.mat

% Choose the set of models to test with MSD-Bayes
msd_params.models = {'D','V','DV'};

% Create a results cell array to store the results of the MSD-Bayes
% analysis for each simulated velocity and each repetition of the
% simulations
results = cell(21,50);

% Create matrices to store the model probabilities for each simulated
% velocity and each repetition of the simulations
D_probabilities = zeros(21,50);
V_probabilities = zeros(21,50);
DV_probabilities = zeros(21,50);

% For each of the simulated velocity values
for v=1:21
    
    % For each of the repetitions
    for n=1:50
        
        % Create matrix of the simulated MSD curves,
        % where the MSD curves are the columns of the matrix
        MSD_curves = [];
        for i=1:30
            MSD_curves(:,i) = MSD_curves_simulated{v,n,i}';
        end
        
        % Run MSD-Bayes to perform Bayesian inference
        results{v,n} = msd_curves_bayes(timelags, MSD_curves, msd_params);
        
        % Store the model probabilities
        D_probabilities(v,n) = results{v,n}.mean_curve.D.PrM;
        V_probabilities(v,n) = results{v,n}.mean_curve.V.PrM;
        DV_probabilities(v,n) = results{v,n}.mean_curve.DV.PrM;
    
    end
    
end


figure('Position',[100 100 550 360])
hold on
errorbar(velocities, mean(D_probabilities,2), std(D_probabilities,[],2),'o-','Color','k','markersize',10)
errorbar(velocities, mean(V_probabilities,2), std(V_probabilities,[],2),'s-','Color','k','markersize',10)
errorbar(velocities, mean(DV_probabilities,2), std(DV_probabilities,[],2),'^-','Color','k','markersize',10)
set(gcf,'Color','w')
set(gca,'FontSize',18)
set(gca,'box','on')
set(gca,'XScale','log')
ylabel('Model probability')
xlabel('Velocity [\mum/s]')
ylim([0 1])
xlim([velocities(1) velocities(end)])
legend(msd_params.models,'Location','NorthEastOutside')
legend boxoff





