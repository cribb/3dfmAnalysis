function varforce_plot_drift_vectors(data)
% VARFORCE_PLOT_DRIFT_VECTORS plots the x vs y drift velocities
%
% 3DFM function  
% Magnetics/varforce
% last modified 11/17/08 (krisford)
%
% varforce plotting function that plots the x vs y drift velocities
% This provides information regarding the average magnitude and direction 
% of the drift as well as the variance around that average.
%
% varforce_plot_drift_vectors(data)
%
% where data is the 'data' substructure of the varforce output structure
%


  X_DRIFT = 1;
  Y_DRIFT = 2;
  
  x_vector = data.drift_vectors(:,X_DRIFT) * 1e6;
  y_vector = data.drift_vectors(:,Y_DRIFT) * 1e6;

  xv_mean     = mean(x_vector);
  yv_mean     = mean(y_vector);
  
      h = figure;

      set(h, 'Name', 'varforce: Drift Velocities')
      set(h, 'NumberTitle', 'off');

      plot(x_vector, y_vector, 'b.', xv_mean, yv_mean, 'r*');
      set(gca, 'Xlim', [-range(x_vector) range(x_vector)]);      
      set(gca, 'Ylim', [-range(y_vector) range(y_vector)]);
      drawnow;

      drawlines(gca, [0], 'k', '-', [], [0], 'k', '-', [] );
             
      xlabel('x velocity [\mum/s]');
      ylabel('y velocity [\mum/s]');

      pretty_plot;
      drawnow;

return
