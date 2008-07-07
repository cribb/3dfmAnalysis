function v = legend_reorder(figh, reorderseq)

figure(figh);

ax = get(figh, 'Children');

ser = get(ax, 'Children');

[legend_h,object_h,plot_h,text_strings] = legend

% s = get(c, 'String');
% 

set(ax, 'Children', ser(reorderseq));
set(legend_h, 'String', text_strings(reorderseq));

legend off;
legend on;

v = 0;

