function [figh,p] = plot_msd_boxplot(msd_summary_struct, compare_data_label)
% 

ins = msd_summary_struct;

data_labels = ins.data_labels;
logmsd = log10(ins.msd);
Nestimates = ins.Nestimates;
taus = ins.tau;

N = size(logmsd,1); % max number of sample for at least one of the columns
M = size(logmsd,2); % number of files/data_labels/categories/conditions

for k = 1:M
    if strcmp(data_labels{k},compare_data_label)
        COMPARE_COLUMN = k;
        continue;
    end
    
    if ~exist('COMPARE_COLUMN', 'var') && k == M
        error('Data label not found');
    end
end

% do the basic plotting first
figh = figure;
boxplot(logmsd, 'labels', msd_summary_struct.data_labels, 'notch', 'on');
title('MSD Distributions')
% ylim([-16, -12])    
% set(gca, 'YTick', [-16; -15; -14; -13; -12])    
% ylabel('log_{10} MSD [m^2] at \tau = 1 sec');
ylabel('log_{10} MSD [m^2]');
pretty_plot;

% then set everything up for determining significances
compare_msd = logmsd(~isnan(logmsd(:,COMPARE_COLUMN)),COMPARE_COLUMN);

for k = 1:M
    this_msd = logmsd(~isnan(logmsd(:,k)),k);
    this_Nestimates = Nestimates(~isnan(logmsd(:,k)),k);
        
    [p(k),h(k)] = ranksum(compare_msd, this_msd);
    
%     % if there's significance, put the stars on the plot
%     if p(k)<0.05
%         sigstar([k,COMPARE_COLUMN],p(k)); 
%     end
    
end

return;