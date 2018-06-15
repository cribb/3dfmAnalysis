% fubar = cell2mat(vertcat(bigtable.Xdiff(bigtable.SampleName == 'HBE_4pct' & bigtable.Tau == 17)));

d = hbe4pct; 

bigtable = join(d.MsdTable, d.VidTable);
% bigtable = join(d.MsdTable, d.VidTable(:, {'Fid', 'Fps', 'Calibum'}));

sample_names = string(unique(bigtable.SampleName));

h = figure; j = figure;

tau_1s = 40; % Lag step closest to 1 sec. XXX TODO consider modification to msd_gen_taus to select windows at "convenient" time steps, e.g. 1 sec here would be 42 not 40
for k = 1:length(sample_names)
    myname = sample_names(k);
    test_condition = bigtable.SampleName == sample_names(k) & bigtable.Tau == tau_1s;
    xdiff = bigtable.Xdiff(test_condition);
    calibm = bigtable.Calibum(test_condition).*1e-6;
    calibm = mat2cell(calibm, ones(length(calibm), 1));
    selected_data = cellfun(@(x,y) x.*y, xdiff, calibm, 'UniformOutput', false);
    selected_data = vertcat(selected_data);
    selected_data = cell2mat(selected_data);

    figure(h); 
    hold on;
    histogram(selected_data);
    legend(sample_names, 'Interpreter', 'none');
    
    figure(j);
    subplot(1,3,k);
    histfit(selected_data);
    fits(k) = fitdist(selected_data, 'normal');
    title(sample_names(k), 'Interpreter', 'none');
    xlabel('step disp in [m] at \tau =1 s');
    ylabel('count');
end


g = findgroups(d.MsdTable.Fid, d.MsdTable.ID);
figure; 
gplotmatrix(log10(hbe4pct.MsdTable.Tau*1/42), log10(hbe4pct.MsdTable.MsdX), g);