function h = bayes_plot_msd_by_color_jac(bayes_struct, h)

if nargin < 2 || isempty(h)
    h = figure;
end

model = bayes_struct.results.model;
mymsd = bayes_struct.results.orig_msd;

% temp function
global cellfind 
cellfind = @(string)@(cell_contents)(strcmp(string,cell_contents));




model_list = unique(model);

for k = 1: length(model_list);
    cluster(k).model = model_list{k};
    idx = cellfun(cellfind(cluster(k).model), model);
    cluster(k).tau = mymsd.tau(:,idx);
    cluster(k).msd = mymsd.msd(:,idx);
end;

% Generate the plot
figure(h);

hold on;
for k = 1: length(model_list)  
    plot(log10(cluster(k).tau), log10(cluster(k).msd), 'Color', modelcolor(model_list(k)));
end
hold off;  
  

xlabel('log_{10}(\tau) [s]');
ylabel('log_{10}(MSD) [m^2]');

grid on;
box on;
pretty_plot;

return;

function mc = modelcolor(model_in)
    global cellfind
    rgb = @(c)(rem(floor((strfind('kbgcrmyw', c) - 1) * [0.25 0.5 1]), 2));
    
    avail_models = { 'N', 'D', 'DA', 'DR', 'V', ' ' };
    mycolormap = [ rgb('k') ; rgb('m') ; rgb('g') ; rgb('r') ; 0.68, 0.47, 0 ; 0.8 0.8 0.8];
    poop = cellfun(cellfind(model_in), avail_models);    
    mc = mycolormap( poop, :);
return;
