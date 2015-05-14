function bar_fig = bayes_plot_bar_model_freq(q)
%BAYES_PLOT_BAYES_MODEL_FREQ plots the bar graph of count versus Bayesian model 
%                     for curves inside q
%
% Created:       3/3/13, Luke Osborne
% Last modified: 3/3/14, Luke Osborne 
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

% determine the total count
total_count = length(q.model);


% generates the model count list

for i = 1:length(q.model)
    if strcmp(q.model(i), 'N')
       N_model = N_model + 1;
    end 
end
model_count_list = [model_count_list N_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'D')
       D_model = D_model + 1;
    end
end
model_count_list = [model_count_list D_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'DA')
       DA_model = DA_model + 1;
    end
end
model_count_list = [model_count_list DA_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'DR')
       DR_model = DR_model + 1;
    end
end
model_count_list = [model_count_list DR_model];

for i = 1:length(q.model)
    if strcmp(q.model(i), 'V')
       V_model = V_model + 1;
    end
end
model_count_list = [model_count_list V_model];



model_freq_list = model_count_list / total_count;



bar_fig = figure;
bar_model_freq = bar(diag(model_freq_list), 'stacked');
title(q.name)
ylim([0 1])
set(gca, 'XTickLabel', models);
ylabel('frequency');
xlabel('model type');

set(bar_model_freq(1), 'facecolor', 'k')
set(bar_model_freq(2), 'facecolor', 'm')
set(bar_model_freq(3), 'facecolor', 'g')
set(bar_model_freq(4), 'facecolor', 'r')
%set(bar_model_freq(5), 'facecolor', 'b')
set(bar_model_freq(5), 'facecolor', [0.68,0.47,0])

pretty_plot;


end



% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DV')
%        DV_model = DV_model + 1;
%     end
% end
% model_count_list = [model_count_list DV_model];
% 
% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DAV')
%        DAV_model = DAV_model + 1;
%     end
% end
% model_count_list = [model_count_list DAV_model];
% 
% for i = 1:length(q.model)
%     if strcmp(q.model(i), 'DRV')
%        DRV_model = DRV_model + 1;
%     end
% end
% model_count_list = [model_count_list DRV_model];


