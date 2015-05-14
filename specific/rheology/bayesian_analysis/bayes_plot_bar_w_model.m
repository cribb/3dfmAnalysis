function bar_w_model = bayes_plot_bar_w_model(q)
%BAYES_PLOT_BAY_W_MODEL plots the bar graph of count*probability versus Bayesian model 
%                     for curves inside q
%
% Created:       1/28/14, Luke Osborne
% Last modified: 2/5/14, Luke Osborne 
%
% inputs:   q       this is a video, which may have multiple trackers
%          
% outputs:  h       bar plot
%
% 


models = {'N', 'D', 'DA', 'DR', 'V'};
%models = {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};

% initializing model bin counts
N_model   = 0;
D_model   = 0;
DA_model  = 0;
DR_model  = 0;
V_model   = 0;
% DV_model  = 0;
% DAV_model = 0;
% DRV_model = 0;


% initializing the model count list
model_count_list=[];


% generates the model count list

for i = 1:length(q.model)
    if strcmp(q.model(i), 'N')
       N_model = N_model + q.prob(i);
    end 
end
model_count_list = [model_count_list N_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'D')
       D_model = D_model + q.prob(i);
    end
end
model_count_list = [model_count_list D_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'DA')
       DA_model = DA_model + q.prob(i);
    end
end
model_count_list = [model_count_list DA_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'DR')
       DR_model = DR_model + q.prob(i);
    end
end
model_count_list = [model_count_list DR_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'V')
       V_model = V_model + q.prob(i);
    end
end
model_count_list = [model_count_list V_model];

% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DV')
%        DV_model = DV_model + q.prob(i);
%     end
% end
% model_count_list = [model_count_list DV_model];
% 
% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DAV')
%        DAV_model = DAV_model + q.prob(i);
%     end
% end
% model_count_list = [model_count_list DAV_model];
% 
% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DRV')
%        DRV_model = DRV_model + q.prob(i);
%     end
% end
% model_count_list = [model_count_list DRV_model];




bar_w_model = figure;
bar(model_count_list)
ylim([0 120])
set(gca, 'XTickLabel', models);
ylabel('(count) * (model probability)');
xlabel('model type');
pretty_plot;


end



