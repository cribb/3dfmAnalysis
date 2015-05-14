function bayes_pub = bayes_publish(bayes_output, bayes_model_output, k_norm)


% % START REPORT GENERATION TO HTML PAGE

outfile = ['~bayes' '.html'];
fid = fopen(outfile, 'w');


units = {'um^2', 'um^2/s', 'um^2/s', '-', 'um^2/s', 'um', 'um/s'}';




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Model Parameter Plots from Ensemble Statistics
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

param_struct = bayes_ensemble_analysis(bayes_output);

% Generate the N vs condition bar plot
bar_N = plot_param_N(param_struct);
barparam_N = 'barplot_N';
gen_pub_plotfiles(barparam_N, bar_N, 'normal')
close(bar_N);
drawnow;

% Generate the D vs condition bar plot
bar_D = plot_param_D(param_struct);
barparam_D = 'barplot_D';
gen_pub_plotfiles(barparam_D, bar_D, 'normal')
close(bar_D);
drawnow;

% Generate the DA:D vs condition bar plot
bar_DA_D = plot_param_DA_D(param_struct);
barparam_DA_D = 'barplot_DA_D';
gen_pub_plotfiles(barparam_DA_D, bar_DA_D, 'normal')
close(bar_DA_D);
drawnow;

% Generate the DA:A vs condition bar plot
bar_DA_A = plot_param_DA_A(param_struct);
barparam_DA_A = 'barplot_DA_A';
gen_pub_plotfiles(barparam_DA_A, bar_DA_A, 'normal')
close(bar_DA_A);
drawnow;

% Generate the DR:D vs condition bar plot
bar_DR_D = plot_param_DR_D(param_struct);
barparam_DR_D = 'barplot_DR_D';
gen_pub_plotfiles(barparam_DR_D, bar_DR_D, 'normal')
close(bar_DR_D);
drawnow;

% Generate the DR:R vs condition bar plot
bar_DR_R = plot_param_DR_R(param_struct);
barparam_DR_R = 'barplot_DR_R';
gen_pub_plotfiles(barparam_DR_R, bar_DR_R, 'normal')
close(bar_DR_R);
drawnow;

% Generate the V vs condition bar plot
bar_V = plot_param_V(param_struct);
barparam_V = 'barplot_V';
gen_pub_plotfiles(barparam_V, bar_V, 'normal')
close(bar_V);
drawnow;





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RMS Disp. Grouped by Model Parameter Plots
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

% Generate the RMS Disp. of Trajectories in the N Model
bar_RMS_N = plot_RMS_N(bayes_output, bayes_model_output);
bar_RMS_N_only = 'bar_RMS_N';
gen_pub_plotfiles(bar_RMS_N_only, bar_RMS_N, 'normal')
close(bar_RMS_N);
drawnow;

% Generate the RMS Disp. of Trajectories in the D Model
bar_RMS_D = plot_RMS_D(bayes_output, bayes_model_output);
bar_RMS_D_only = 'bar_RMS_D';
gen_pub_plotfiles(bar_RMS_D_only, bar_RMS_D, 'normal')
close(bar_RMS_D);
drawnow;

% Generate the RMS Disp. of Trajectories in the DA Model
bar_RMS_DA = plot_RMS_DA(bayes_output, bayes_model_output);
bar_RMS_DA_only = 'bar_RMS_DA';
gen_pub_plotfiles(bar_RMS_DA_only, bar_RMS_DA, 'normal')
close(bar_RMS_DA);
drawnow;

% Generate the RMS Disp. of Trajectories in the DR Model
bar_RMS_DR = plot_RMS_DR(bayes_output, bayes_model_output);
bar_RMS_DR_only = 'bar_RMS_DR';
gen_pub_plotfiles(bar_RMS_DR_only, bar_RMS_DR, 'normal')
close(bar_RMS_DR);
drawnow;

% Generate the RMS Disp. of Trajectories in the V Model
bar_RMS_V = plot_RMS_V(bayes_output, bayes_model_output);
bar_RMS_V_only = 'bar_RMS_V';
gen_pub_plotfiles(bar_RMS_V_only, bar_RMS_V, 'normal')
close(bar_RMS_V);
drawnow;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RMS Disp. Grouped by Several Model Parameters
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

% Generate the RMS Disp. of Trajectories in the DA and DR Models
bar_RMS_DA_DR = plot_RMS_DA_DR(bayes_output, bayes_model_output);
bar_RMS_DA_DR_only = 'bar_RMS_DA_DR';
gen_pub_plotfiles(bar_RMS_DA_DR_only, bar_RMS_DA_DR, 'normal')
close(bar_RMS_DA_DR);
drawnow;




test = bayes_model_output;


%
% HTML CODE
%
fprintf(fid, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" ');
fprintf(fid, '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> \n');
fprintf(fid, '<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">\n\n');
fprintf(fid, '<head> \n');
fprintf(fid, '<title> Development Tool for Bayesian Analysis of MSD Trajectories </title>\n');
fprintf(fid, '</head>\n\n');
fprintf(fid, '<body>\n\n');

%
% Headers
%
fprintf(fid, '<h1> Development Tool: Bayesian Analysis of MSD Trajectories </h1> \n');
fprintf(fid, '<p> \n');
fprintf(fid, '   <b>Path:</b>  %s <br/>\n', pwd);
fprintf(fid, '   <b>Filename:</b>  %s <br/>\n', outfile);
fprintf(fid, '   <b>Minimum number of frames per trajectory:</b>  %s <br/>\n', num2str(bayes_output(1,1).min_frames));
fprintf(fid, '   <b>Number of subtrajectories used:</b>  %s \n', num2str(bayes_output(1,1).num_subtraj));
fprintf(fid, '</p> \n\n');
fprintf(fid, '<hr/> \n\n');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MSD plots of aggregated data sets
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> MSD vs Tau for the Aggregated Datasets </h3> \n');

    for k = 1:length(bayes_output)

        
        % Generates the aggregate data MSD plot
        
        if  ~isempty(bayes_output(k,1).agg_data)
            aggregate_data(k) = plot_msd(bayes_output(k,1).agg_data, [], 'ame');
            title(bayes_output(k,1).name)
            ylim([-17,-11])
            xlim([-2,2])

            aggregate_data_msd_plot = ['agg_data_msd' num2str(bayes_output(k,1).name)];
            gen_pub_plotfiles(aggregate_data_msd_plot, aggregate_data(k), 'normal')
            %close(aggregate_data);
            %close(ancestor(aggregate_data, 'figure', 'toplevel'))
            close(findobj('type','figure'))
            drawnow;

            fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img>  \n', aggregate_data_msd_plot);
        else
            aggregate_data(k) = plot(1,2);
            close(findobj('type','figure'))
        end
    end
    
fprintf(fid, '   <br/> \n\n');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MSD plots colorized by model type
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

for k = 1:length(bayes_model_output)

    model_curve_struct.N_curve_struct  = bayes_model_output(k,1).N_curve_struct;
    model_curve_struct.D_curve_struct  = bayes_model_output(k,1).D_curve_struct;
    model_curve_struct.DA_curve_struct = bayes_model_output(k,1).DA_curve_struct;
    model_curve_struct.DR_curve_struct = bayes_model_output(k,1).DR_curve_struct;
    model_curve_struct.V_curve_struct  = bayes_model_output(k,1).V_curve_struct;

    msd_color(k) = bayes_plot_msd_by_color(model_curve_struct);
    title(bayes_output(k,1).name)
    ylim([-17,-11])
    xlim([-2,2])

    msd_by_color = ['msd_by_color' num2str(bayes_output(k,1).name)];
    gen_pub_plotfiles(msd_by_color, msd_color(k), 'normal')
    close(msd_color);
    drawnow;

    fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img>  \n', msd_by_color);        
end

fprintf(fid, '   <br/> \n\n');

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% creating the DA model structure to be used for:
%%% 1. DA model: MSD vs tau plots
%%% 2. ANOVA statistics testing
%%%
%%% NOTE:  other functions could use this, but I am not going back to
%%% retrofit this into all previously written code... (7/3/14)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
for k = 1:length(bayes_model_output) 

    DA_struct(k,1).curves = bayes_model_output(k,1).DA_curve_struct;
    DA_struct(k,1).name   = bayes_model_output(k,1).name;
    
end  % for loop    
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% generating a DA only MSD vs tau plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
for k = 1:length(bayes_model_output)

    current_DA_struct = DA_struct(k,1);
    
    msd_vs_tau_DA(k) = bayes_plot_msd_v_tau_DA(current_DA_struct);
    title(bayes_output(k,1).name)
    ylim([-17,-11])
    xlim([-2,2])

    msd_vs_tau_DA_model = ['msd_vs_tau_DA_model' num2str(bayes_output(k,1).name)];
    gen_pub_plotfiles(msd_vs_tau_DA_model, msd_vs_tau_DA(k), 'normal')
    close(msd_vs_tau_DA);
    drawnow;

    fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img>  \n', msd_vs_tau_DA_model);       
        
end  % for loop    
    
    
    
    

% Generates the histogram of model types by frequency
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Histograms of Bayesian Model Analysis </h3> \n');

    for k = 1:length(bayes_output)

        %bar_model_freq(k) = bayes_plot_bar_model_freq(bayes_output(k,1));
        bar_model_freq = bayes_plot_bar_model_freq(bayes_output(k,1));
        % aggdata_bar_model_freq = 'aggdata_bar_model_freq';
        aggdata_bar_model_freq = ['bar_plot' num2str(bayes_output(k,1).name)];
        %gen_pub_plotfiles(aggdata_bar_model_freq, bar_model_freq(k), 'normal')
        gen_pub_plotfiles(aggdata_bar_model_freq, bar_model_freq, 'normal')
        close(bar_model_freq);
        drawnow;

        fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', aggdata_bar_model_freq);

    end 
    
fprintf(fid, '   <br/> \n\n');




% Generates the histogram of model types by count
%
fprintf(fid, '<p> \n');

    for k = 1:length(bayes_output)

        %bar_model_count(k) = bayes_plot_bar_by_model(bayes_output(k,1));
        bar_model_count = bayes_plot_bar_by_model(bayes_output(k,1));
        aggdata_bar_model_count = ['bar_plot_count' num2str(bayes_output(k,1).name)];
        %gen_pub_plotfiles(aggdata_bar_model_count, bar_model_count(k), 'normal')
        gen_pub_plotfiles(aggdata_bar_model_count, bar_model_count, 'normal')
        close(bar_model_count);
        drawnow;
       
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', aggdata_bar_model_count);

    end 
    
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '<hr/> \n\n');







% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Combined Summary Table with Model 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves within each Population across Conditions </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> C [um^2] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> C error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> C prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D [um^2/sec] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D, DA [um^2/sec] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DA prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> alpha, DA </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> alpha error prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DA prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D, DR [um^2/sec] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DR prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> R, DR [um] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> R error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DR prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> V [um/s] </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> V error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> V prob. </b> </td> \n');
% fprintf(fid, '    </tr>\n');
% % Fill in Summary table with data
% for k = 1:length(bayes_model_output)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', bayes_model_output(k,1).name);
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).N(1,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).N(1,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).N(1,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).D(2,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).D(2,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).D(2,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DA(3,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DA(3,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).DA(3,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DA(4,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DA(4,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).DA(4,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DR(5,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DR(5,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).DR(5,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DR(6,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).DR(6,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).DR(6,3));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).V(7,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_model_output(k,1).V(7,2));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_model_output(k,1).V(7,3));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% 
% 
% 
% 
% % Comparison of Model Parameters across Conditions
% 
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Comparison of Model Parameters across Conditions </h3> \n');
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_C);
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_D);
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_V);
% fprintf(fid, '   <br/> \n\n');
% fprintf(fid, '</p> \n\n');
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_DA_D);
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_DA_A);
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_DR_D);
% fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_param_DR_R);
% fprintf(fid, '   <br/> \n\n');
% fprintf(fid, '<hr/> \n\n');






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ensemble Paramter Table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


param_struct = bayes_ensemble_analysis(bayes_output);


fprintf(fid, '   <h3> Ensemble Statistics of Model Parameters from Passing of Subtrajectories into Bayesian Analysis </h3> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> N [um^2] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> N count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> D [um^2/s] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> D count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DA:D [um^2/s] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DA:A </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');

fprintf(fid, '      <td align="center" width="80"> <b> DA:A Median </b> </td> \n');

fprintf(fid, '      <td align="center" width="80"> <b> DA count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DR:D [um^2/s] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DR:R [um] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DR count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> V [um/s] </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> V count </b> </td> \n');
fprintf(fid, '    </tr>\n');
% Fill in Summary table with data
for k = 1:length(bayes_model_output)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', param_struct(k,1).name);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).N_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).N_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', param_struct(k,1).N_count);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).D_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).D_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', param_struct(k,1).D_count);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_D_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_D_se);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_A_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_A_se);

fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_A_median);

fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', param_struct(k,1).DA_count);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DR_D_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DR_D_se);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DR_R_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DR_R_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', param_struct(k,1).DR_count);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).V_mean);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).V_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', param_struct(k,1).V_count);
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');



% Comparison of Model Parameters across Conditions

fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Comparison of Model Parameters across Conditions </h3> \n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_N);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_D);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_V);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_DA_D);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_DA_A);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_DR_D);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', barparam_DR_R);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '<hr/> \n\n');







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RMS Disp. Table 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


RMS_struct = bayes_calc_RMS(bayes_output, bayes_model_output);

% Generate the N model matrix of log10 msd values at 1 sec
[ LOG10_msdN_matrix ] = gen_msdN_matrix( bayes_model_output );

% calculating the median RMS of N model
for i = 1:size(LOG10_msdN_matrix, 2)
    median_N_model_MSD(i) = 10.^nanmedian(LOG10_msdN_matrix(:,i));
    median_N_model_RMS(i) = sqrt(median_N_model_MSD(i))*1E9;
end

fprintf(fid, '   <h3> RMS Disp. of Trajectories within each Model Type in [nm] </h3> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> N RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> N RMS Median </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> N count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> D RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> D count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DA RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DA count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DR RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DR count </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> V RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> V count </b> </td> \n');
fprintf(fid, '    </tr>\n');
% Fill in Summary table with data
for k = 1:length(bayes_model_output)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', RMS_struct(k,1).name);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).N);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).N_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', median_N_model_RMS(k));
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).N_count);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).D);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).D_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).D_count);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DA);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DA_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).DA_count);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DR);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DR_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).DR_count);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).V);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).V_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).V_count);
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');





% RMS Disp. of Trajectories Belonging to Particular Model Types

fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> RMS Disp. of Trajectories Belonging to Particular Model Types </h3> \n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_N_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_D_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_V_only);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_DA_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_DR_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_DA_DR_only);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '<hr/> \n\n');



   

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % FINAL SUMMARY PLOTS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RMS, G, Eta, Count for "All" --> all models aggregated
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

%RMS_struct = bayes_calc_RMS(bayes_output, bayes_model_output);

fprintf(fid, '   <h3> Summary of Final Plots </h3> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> MSD All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> RMS All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Count All </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(bayes_model_output)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', RMS_struct(k,1).name);
fprintf(fid, '      <td align="center" width="80"> %8.4g </td> \n', RMS_struct(k,1).MSD_agg);
fprintf(fid, '      <td align="center" width="80"> %8.4g </td> \n', RMS_struct(k,1).MSD_agg_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).agg);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).agg_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_agg);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_agg_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_agg);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_agg_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).count_agg);
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RMS, G, Eta, Count for DA and DR models
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> MSD All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> RMS DA and DR </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G DA and DR </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta DA and DR </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Count DA and DR </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(bayes_model_output)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', RMS_struct(k,1).name);
fprintf(fid, '      <td align="center" width="80"> %8.4g </td> \n', RMS_struct(k,1).MSD_DA_DR);
fprintf(fid, '      <td align="center" width="80"> %8.4g </td> \n', RMS_struct(k,1).MSD_DA_DR_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).RMS_DA_DR);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).RMS_DA_DR_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_DA_DR);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_DA_DR_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_DA_DR);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_DA_DR_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).count_DA_DR);
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % RMS, G, Eta, Count for DA 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

%%% perform t-tests and Mann-Whitney U test (rank-sum test) on DA only data sets 
%%% in MSD space, compared to k_norm condition

[ LOG10_msdDA_matrix ] = gen_msdDA_matrix( bayes_model_output );
[ p_value ]            = bayes_ttest2( LOG10_msdDA_matrix, k_norm );
[ p_value_ranksum ]    = bayes_ranksum( LOG10_msdDA_matrix, k_norm );
[ skewnessDA_array, kurtosisDA_array, p_value_SW ] = bayes_normalityTest( LOG10_msdDA_matrix );

% calculating the median MSD and RMS
for i = 1:size(LOG10_msdDA_matrix, 2)
    median_MSD_DA(i) = 10.^nanmedian(LOG10_msdDA_matrix(:,i));
    median_RMS_DA(i) = sqrt(median_MSD_DA(i))*1E9;
end

% generating the alpha_matrix. Next line is used above to create the param_struct
%param_struct = bayes_ensemble_analysis(bayes_output);
for k = 1:length(param_struct)
    new_column = param_struct(k,1).DA_A_dist'; 
    if length(new_column) <= 500
        a = 500 - length(new_column);
        dummy_matrix = NaN(1,a);
        new_column = horzcat(new_column, dummy_matrix);   
    else
        fprintf('There are more than 500 beads.  Need to change the dummy_matrix limits.');
    end
    new_column = new_column';
    alpha_matrix(:,k) = new_column(:);
end
[ p_value_ranksum_alpha ]    = bayes_ranksum( alpha_matrix, k_norm );

fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> MSD All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM All </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> RMS DA </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G DA </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> G SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta DA </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Eta SEM </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Count DA </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Median MSD </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Median RMS </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> p-value   t-test </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> p-value Mann-Whitney </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> skewness </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> kurtosis </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> p-value Shapiro-Wilk </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> DA:A Median </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> p-value Mann-Whitney </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(bayes_model_output)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', RMS_struct(k,1).name);
fprintf(fid, '      <td align="center" width="80"> %8.3g </td> \n', RMS_struct(k,1).MSD_DA);
fprintf(fid, '      <td align="center" width="80"> %8.3g </td> \n', RMS_struct(k,1).MSD_DA_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DA);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).DA_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_DA);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).G_DA_se);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_DA);
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', RMS_struct(k,1).eta_DA_se);
fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', RMS_struct(k,1).DA_count);
fprintf(fid, '      <td align="center" width="80"> %8.2g </td> \n', median_MSD_DA(k));
fprintf(fid, '      <td align="center" width="80"> %8.2f </td> \n', median_RMS_DA(k));
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', p_value(k));
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', p_value_ranksum(k));
fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', skewnessDA_array(k));
fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', kurtosisDA_array(k));
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', p_value_SW(k));
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', param_struct(k,1).DA_A_median);
fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', p_value_ranksum_alpha(k));
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');




fprintf(fid, '<hr/> \n\n');
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Final Plots </h3> \n');


bar_MSD_agg = plot_MSD_agg(bayes_output);
bar_MSD_agg_plot = 'bar_plot_MSD_agg';
gen_pub_plotfiles(bar_MSD_agg_plot, bar_MSD_agg, 'normal')
close(bar_MSD_agg);
drawnow;

bar_MSD_DADR = plot_MSD_DADR(bayes_output, bayes_model_output);
bar_MSD_DADR_plot = 'bar_plot_MSD_DADR';
gen_pub_plotfiles(bar_MSD_DADR_plot, bar_MSD_DADR, 'normal')
close(bar_MSD_DADR);
drawnow;


bar_MSD_DA = plot_MSD_DA(bayes_output, bayes_model_output);
bar_MSD_DA_plot = 'bar_plot_MSD_DA';
gen_pub_plotfiles(bar_MSD_DA_plot, bar_MSD_DA, 'normal')
close(bar_MSD_DA);
drawnow;


bar_RMS = plot_RMS(bayes_output);
bar_RMS_plot = 'bar_plot_RMS';
gen_pub_plotfiles(bar_RMS_plot, bar_RMS, 'normal')
close(bar_RMS);
drawnow;

bar_G = plot_bar_G(bayes_output);
bar_plot_G = 'bar_plot_G';
gen_pub_plotfiles(bar_plot_G, bar_G, 'normal')
close(bar_G);
drawnow;

bar_eta = plot_bar_eta(bayes_output);
bar_plot_eta = 'bar_plot_eta';
gen_pub_plotfiles(bar_plot_eta, bar_eta, 'normal')
close(bar_G);
drawnow;

%%%

bar_G_DA_DR = plot_bar_G_DA_DR(bayes_output, bayes_model_output);
bar_plot_G_DA_DR = 'bar_plot_G_DA_DR';
gen_pub_plotfiles(bar_plot_G_DA_DR, bar_G_DA_DR, 'normal')
close(bar_G_DA_DR);
drawnow;

bar_eta_DA_DR = plot_bar_eta_DA_DR(bayes_output, bayes_model_output);
bar_plot_eta_DA_DR = 'bar_plot_eta_DA_DR';
gen_pub_plotfiles(bar_plot_eta_DA_DR, bar_eta_DA_DR, 'normal')
close(bar_eta_DA_DR);
drawnow;

bar_G_DA = plot_bar_G_DA(bayes_output, bayes_model_output);
bar_plot_G_DA = 'bar_plot_G_DA';
gen_pub_plotfiles(bar_plot_G_DA, bar_G_DA, 'normal')
close(bar_G_DA);
drawnow;

bar_eta_DA = plot_bar_eta_DA(bayes_output, bayes_model_output);
bar_plot_eta_DA = 'bar_plot_eta_DA';
gen_pub_plotfiles(bar_plot_eta_DA, bar_eta_DA, 'normal')
close(bar_eta_DA);
drawnow;


plot_msdBoxPlot = pan_plot_msdBoxPlot(bayes_model_output, LOG10_msdDA_matrix );
box_plot_MSD = 'box_plot_MSD';
gen_pub_plotfiles(box_plot_MSD, plot_msdBoxPlot, 'normal')
close(plot_msdBoxPlot);
drawnow;

plot_alphaBoxPlot = pan_plot_alphaBoxPlot(bayes_model_output, alpha_matrix );
box_plot_alpha = 'box_plot_alpha';
gen_pub_plotfiles(box_plot_alpha, plot_alphaBoxPlot, 'normal')
close(plot_alphaBoxPlot);
drawnow;



fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_MSD_agg_plot);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_plot);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_G);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_eta);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_MSD_DADR_plot);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_DA_DR_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_G_DA_DR);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_eta_DA_DR);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_MSD_DA_plot);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_RMS_DA_only);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_G_DA);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_eta_DA);



fprintf(fid, '<hr/> \n\n');
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Extra Plots </h3> \n');

bar_G_DA_norm = plot_bar_G_DA_norm(bayes_output, bayes_model_output, k_norm);
bar_plot_G_DA_norm = 'bar_plot_G_DA_norm';
gen_pub_plotfiles(bar_plot_G_DA_norm, bar_G_DA_norm, 'normal')
close(bar_G_DA_norm);
drawnow;

bar_eta_DA_norm = plot_bar_eta_DA_norm(bayes_output, bayes_model_output, k_norm);
bar_plot_eta_DA_norm = 'bar_plot_eta_DA_norm';
gen_pub_plotfiles(bar_plot_eta_DA_norm, bar_eta_DA_norm, 'normal')
close(bar_eta_DA_norm);
drawnow;

fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', box_plot_MSD);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', box_plot_alpha);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_G_DA_norm);
fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_eta_DA_norm);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% comparing MSD of different bead sizes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf(fid, '<hr/> \n\n');
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Comparison of DA Model MSDs vs. Bead Size </h3> \n');


[ MSD_beadSize_struct ] = pan_cmp_MSD_beadSize( bayes_model_output, RMS_struct );



fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Comparison </b> </td> \n');
fprintf(fid, '      <td align="center" width="80"> <b> Ratio </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(MSD_beadSize_struct)
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="80"> %s </td> \n', MSD_beadSize_struct(k).labels);
fprintf(fid, '      <td align="center" width="80"> %8.4g </td> \n', MSD_beadSize_struct(k).values);
fprintf(fid, '   </tr>\n');    
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');


bar_MSD_beadSize = plot_bar_MSD_beadSize( MSD_beadSize_struct );
bar_plot_MSD_beadSize = 'bar_plot_MSD_beadSize';
gen_pub_plotfiles(bar_plot_MSD_beadSize, bar_MSD_beadSize, 'normal')
close(bar_MSD_beadSize);
drawnow;

fprintf(fid, '   <img src="%s.png" width=24%% border="0"></img> \n', bar_plot_MSD_beadSize);


% wrap up the file.
fprintf(fid, '</body> \n');
fprintf(fid, '</html> \n\n');

fclose(fid);

bayes_pub.computation_struct = RMS_struct;
bayes_pub.LOG10_msdDA_matrix = LOG10_msdDA_matrix;

return;






% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % Model Parameter Plots for 2nd Run Through Bayesian
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %
% 
% % Generate the N vs condition bar plot
% bar_C = bayes_plot_param_C(bayes_model_output);
% bar_param_C = 'bar_param_C';
% gen_pub_plotfiles(bar_param_C, bar_C, 'normal')
% close(bar_C);
% drawnow;
% 
% % Generate the D vs condition bar plot
% bar_D = bayes_plot_param_D(bayes_model_output);
% bar_param_D = 'bar_param_D';
% gen_pub_plotfiles(bar_param_D, bar_D, 'normal')
% close(bar_D);
% drawnow;
% 
% % Generate the D from DA model vs condition bar plot
% bar_DA_D = bayes_plot_param_DA_D(bayes_model_output);
% bar_param_DA_D = 'bar_param_DA_D';
% gen_pub_plotfiles(bar_param_DA_D, bar_DA_D, 'normal')
% close(bar_DA_D);
% drawnow;
% 
% % Generate the alpha vs condition bar plot
% bar_DA_A = bayes_plot_param_DA_A(bayes_model_output);
% bar_param_DA_A = 'bar_param_DA_A';
% gen_pub_plotfiles(bar_param_DA_A, bar_DA_A, 'normal')
% close(bar_DA_A);
% drawnow;
% 
% % Generate the D from DR model vs condition bar plot
% bar_DR_D = bayes_plot_param_DR_D(bayes_model_output);
% bar_param_DR_D = 'bar_param_DR_D';
% gen_pub_plotfiles(bar_param_DR_D, bar_DR_D, 'normal')
% close(bar_DR_D);
% drawnow;
% 
% % Generate the Confinement Radius vs condition bar plot
% bar_DR_R = bayes_plot_param_DR_R(bayes_model_output);
% bar_param_DR_R = 'bar_param_DR_R';
% gen_pub_plotfiles(bar_param_DR_R, bar_DR_R, 'normal')
% close(bar_DR_R);
% drawnow;
% 
% % Generate the Flow Velocity vs condition bar plot
% bar_V = bayes_plot_param_V(bayes_model_output);
% bar_param_V = 'bar_param_V';
% gen_pub_plotfiles(bar_param_V, bar_V, 'normal')
% close(bar_V);
% drawnow;



% % Generates the aggregate data MSD plot
% aggregate_data = plot_msd(bayes_output.agg_data, [], 'ame');
% ylim([-17,-11])
% aggregate_data_msd_plot = 'agg_data_msd';
% gen_pub_plotfiles(aggregate_data_msd_plot, aggregate_data, 'normal')
% close(aggregate_data);
% drawnow;
%
% % Generates the histogram of model types in the aggregate data
% bar_by_model = bayes_plot_bar_by_model(bayes_output);
% aggdata_bar_by_model = 'aggdata_bar_by_model';
% gen_pub_plotfiles(aggdata_bar_by_model, bar_by_model, 'normal')
% close(bar_by_model);
% drawnow;
% 
% % Generates the histogram of model types weighted by a trajectory's respective probability
% bar_w_model = bayes_plot_bar_w_model(bayes_output);
% aggdata_bar_w_model = 'aggdata_bar_w_model';
% gen_pub_plotfiles(aggdata_bar_w_model, bar_w_model, 'normal')
% close(bar_w_model);
% drawnow;
% 
% % Generates the histogram of model types by frequency
% bar_model_freq = bayes_plot_bar_model_freq(bayes_output);
% aggdata_bar_model_freq = 'aggdata_bar_model_freq';
% gen_pub_plotfiles(aggdata_bar_model_freq, bar_model_freq, 'normal')
% close(bar_model_freq);
% drawnow;





% 
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Ensemble data table
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Ensemble Average of Model Parameters within each Population </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Mean Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Standard Deviation </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Standard Error </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Units </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Count </b> </td> \n');
% fprintf(fid, '    </tr>\n');
% % Fill in Summary table with data
% for k = 1:length(essemble_dataout.table)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', essemble_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', essemble_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', essemble_dataout.table(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', essemble_dataout.table(k,2));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', essemble_dataout.table(k,3));
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', units{k,1});
% fprintf(fid, '      <td align="center" width="80"> %8.0f </td> \n', essemble_dataout.table(k,4));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Combined Summary Table
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves within each Population </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> Units </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> N </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> N Prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> D Prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DA </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DA Prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DR </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> DR Prob. </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> V </b> </td> \n');
% fprintf(fid, '      <td align="center" width="80"> <b> V Prob. </b> </td> \n');
% fprintf(fid, '    </tr>\n');
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.N)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="80"> %s </td> \n', units{k,1});
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_dataout.N(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_dataout.N(k,2));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_dataout.D(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_dataout.D(k,2));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_dataout.DA(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_dataout.DA(k,2));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_dataout.DR(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_dataout.DR(k,2));
% fprintf(fid, '      <td align="center" width="80"> %8.5f </td> \n', bayes_dataout.V(k,1));
% fprintf(fid, '      <td align="center" width="80"> %8.3f </td> \n', bayes_dataout.V(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');

























% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model N
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model N </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Units </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.N)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="100"> %8.5f </td> \n', bayes_dataout.N(k,1));
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', units{k,1});
% fprintf(fid, '      <td align="center" width="100"> %8.3f </td> \n', bayes_dataout.N(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model D
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model D </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.D)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="100"> %8.5f </td> \n', bayes_dataout.D(k,1));
% fprintf(fid, '      <td align="center" width="100"> %8.3f </td> \n', bayes_dataout.D(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model DA
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model DA </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.DA)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="100"> %8.5f </td> \n', bayes_dataout.DA(k,1));
% fprintf(fid, '      <td align="center" width="100"> %8.3f </td> \n', bayes_dataout.DA(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model DR
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model DR </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.DR)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="100"> %8.5f </td> \n', bayes_dataout.DR(k,1));
% fprintf(fid, '      <td align="center" width="100"> %8.3f </td> \n', bayes_dataout.DR(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model V
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model V </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="100"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.V)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="100"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="100"> %8.5f </td> \n', bayes_dataout.V(k,1));
% fprintf(fid, '      <td align="center" width="100"> %8.3f </td> \n', bayes_dataout.V(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model DV
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model DV </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.DV)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="200"> %8.5f </td> \n', bayes_dataout.DV(k,1));
% fprintf(fid, '      <td align="center" width="200"> %8.3f </td> \n', bayes_dataout.DV(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model DAV
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model DAV </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.DAV)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="200"> %8.5f </td> \n', bayes_dataout.DAV(k,1));
% fprintf(fid, '      <td align="center" width="200"> %8.3f </td> \n', bayes_dataout.DAV(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Report Summary table for Model DRV
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fprintf(fid, '<p> \n');
% fprintf(fid, '   <h3> Bayesian Model Analysis of Curves in Model DRV </h3> \n');
% fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Model </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Parameter </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Value </b> </td> \n');
% fprintf(fid, '      <td align="center" width="200"> <b> Probability </b> </td> \n');
% fprintf(fid, '    </tr>\n');         
% % Fill in Summary table with data
% for k = 1:length(bayes_dataout.DRV)
% fprintf(fid, '   <tr> \n');
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,1});
% fprintf(fid, '      <td align="center" width="200"> %s </td> \n', bayes_dataout.headings{k,2});
% fprintf(fid, '      <td align="center" width="200"> %8.5f </td> \n', bayes_dataout.DRV(k,1));
% fprintf(fid, '      <td align="center" width="200"> %8.3f </td> \n', bayes_dataout.DRV(k,2));
% fprintf(fid, '   </tr>\n');    
% end
% fprintf(fid, '   </table>\n');
% fprintf(fid, '</p> \n');
% fprintf(fid, '<hr/> \n\n');








