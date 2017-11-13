function h = pan_plot_drift(drift_file)

% if ~isstruct(drift_file)
%     error('Not a drift_file. This function requires drift structure from panoptes functions in 3dfmAnalysis package.');    
% elseif isstruct(drift_struct) && ismember(drift_struct, '')
%     
% else
% end

h = figure; 

drift_struct = load(drift_file);

h = plot_drift_commonmode(drift_struct, h);

return;

function h = plot_drift_commonmode(ds, h)

% "ds" = drift_struct

    if nargin < 2 || isempty(h)
        h = figure; 
    end

    maxframe = cellfun(@max, ds.frame, 'UniformOutput', false);
    maxframe = max(cell2mat(maxframe));        

    miny_cell = cellfun(@min, ds.xy, 'UniformOutput', false);
    miny_mat = cell2mat(miny_cell);
    miny = min(miny_mat(:));

    maxy_cell = cellfun(@max, ds.xy, 'UniformOutput', false);
    maxy_mat = cell2mat(maxy_cell);
    maxy = max(maxy_mat(:));    
                
                
    figure(h); 
    hold on; 
        for k = 1:length(ds.frame)
%             fprintf('f: %i, length(xy): %i\n', k, length(xy{k})); 
            subplot(1,2,1);
            if k == 1
                xlabel('frame #');
                xlim([0 maxframe*1.02]);
                ylim([miny*1.02 maxy*1.02]);
                title('common-modes: x');
                hold on;
            end
            
            try 
                plot(ds.frame{k}, ds.xy{k}(:,1), 'Color', [k/length(ds.frame) 0 (length(ds.frame)-k)/length(ds.frame)]); 
            catch
            end; 

            subplot(1,2,2);
            if k ==1
                xlabel('frame #');
                xlim([0 maxframe*1.02]);
                ylim([miny*1.02 maxy*1.02]);
                title('common-modes: y');
                hold on;
            end
            
            try 
                plot(ds.frame{k}, ds.xy{k}(:,2), 'Color', [0 k/length(ds.frame) (length(ds.frame)-k)/length(ds.frame)]); 
            catch
            end; 
            drawnow; 

            if k == length(ds.frame)
                hold off;
            end
        end; 


return;

% f2 = figure;
% figure(f2);
% 
% for k = 1:length(frame); 
%     fprintf('%i\n',k); 
%     try
%         yvel(k,1) = mean(diff(xy{k}(:,2)))/max(frame{k})*myfps; 
%     end
% end;


