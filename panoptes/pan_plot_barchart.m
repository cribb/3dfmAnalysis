function barfig = pan_plot_barchart(metadata, mymsd, myerr)


    % One-dimensional bar chart
    MSD = (10 .^ mymsd);
    MSD_err = (10.^(mymsd+myerr)-10.^(mymsd));
    barfig = figure('Visible', 'off');
    barwitherr( MSD_err, MSD );
    set(gca, 'XTick', 1:length(data_for_myparam));
    set(gca,'XTickLabel',data_for_myparam)
    xlabel('Well ID');
    ylabel('MSD [m^2] at \tau=10 [s]');
    barfile = [metadata.instr.experiment '_well_ALL' '.bar'];
    gen_pub_plotfiles(barfile, barfig, 'normal');
    close(barfig);
    drawnow;