function bar_MSD_beadSize = plot_bar_MSD_beadSize( MSD_beadSize_struct )


for k = 1:length(MSD_beadSize_struct)
    
    values(k) = MSD_beadSize_struct(k).values;
    labels{k} = MSD_beadSize_struct(k).labels;
    
end

bar_MSD_beadSize = figure;
bar(values)
title('DA Model Only')
ylim([0 4])
set(gca,'YTick',[0 0.5 1 1.5 2 2.5 3 3.5 4])
set(gca, 'XTickLabel', labels);
ylabel('Ratio of MSD values at \tau = 1 sec');
pretty_plot;


end

