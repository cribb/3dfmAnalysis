function [ msdFit_struct ] = panoptesMSDFIT( data, contractMSDyn, decades_to_remove, temperature, expected_values)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Produces a 1x96 structure that has the following fields: (one column for each well of 96 well plate)
%%%           
%%% 1. eta_fit
%%% 2. percent_error
%%%
%%%
%%% Procedural roadmap:
%%% 
%%% 0. inputs: saved workspace from 'pan_process_PMExpt' analysis
%%%            contract MSDs?: 'y' if you want to contract, 'n' if not
%%%            decades to remove: e.g. '1' for 10 sec 
%%% 1. pull avg MSD curve data from the input struct of saved workspace
%%% 2. if there is data in the well, perform the fit
%%% 3. compute eta_fit and store in struct
%%% 4. compute percent_error and store in struct
%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% defaults to a fit of the non-contracted MSD data
if nargin < 3 || isempty(decades_to_remove)
    contractMSDyn = 'n';
    decades_to_remove = 0;
end


clear msdData tauData all_errs

all_msds = data.all_msds;  % 32x96 matrix of mean MSD for each well (32 taus)
all_taus = data.all_taus;
all_errs = data.all_errs;

msdFit_struct = struct;

for i = 1:96
    
    msdData = all_msds(:,i);
    tauData = all_taus(:,i);
    errData = all_errs(:,i);
    
    if isnan(msdData(1))  % if there is no data in the well
        msdFit_struct(i).eta_fit = NaN;     
    else                  % if there is data in the well, do the fit
        
        % removes NaN from mean msd data, shortens mean tau data to match
        msdData(any(isnan(msdData),2),:)=[];
        tauData = tauData(1:length(msdData));
        errData = errData(1:length(msdData));

        if contractMSDyn == 'y'   % if 'n', you will skip this block
            last_pos = length(msdData);     % determines last point in MSD data
            tauData = tauData(1:last_pos);  % determines new tau vector
            target_last_tau = tauData(last_pos) - decades_to_remove;
            
            [minval, minloc] = min( sqrt((tauData - target_last_tau).^2) );
    
            msdData = msdData(1:minloc);            % reassigns MSD data
            tauData = tauData(1:length(msdData));   % reassigns tau data
            errData = errData(1:length(msdData));   % reassigns err data
            
            % contract MSD at short timescales for karo wells only
            if i >= 37 && i <= 48 || i >= 85 && i <= 96
                
                spec_tau = 1; % we want our karo MSD curves to start at 1 sec
                
                [minval_karo, minloc_karo] = min( sqrt((tauData - log(spec_tau)).^2) );
                
                msdData = msdData(minloc_karo:end);   % reassigns MSD data
                tauData = tauData(minloc_karo:end);   % reassigns tau data
                errData = errData(minloc_karo:end);   % reassigns err data
                          
            end % short timescale MSD contraction 
        end % long timescale MSD contraction
        

        % if there is only 1 data point at last tau, error is 0; Thus, we 
        % want to remove this point from the fit
        if errData(end) == 0   
            msdData = msdData(1:end-1);
            tauData = tauData(1:end-1);
            errData = errData(1:end-1);
        end
        
        % save data to output structure
        msdFit_struct(i).data.msdData = msdData;
        msdFit_struct(i).data.tauData = tauData;
        msdFit_struct(i).data.errData = errData;
        
        % creating weighted data
        errData_norm = errData / min(errData) ;
        weights = 1 ./ errData_norm;
        msdDataw = sqrt(weights) .* msdData;
       
        % fitting the data to find constant C
        Fn_msd = @(C,tauData) tauData + C;
        C_0 = -11.5;
        
        Fn_msdw = @(C,tauData) sqrt(weights) .* Fn_msd(C,tauData);
        [Cw,residualsw,Jw,Sigmaw,msew] = nlinfit(tauData, msdDataw, Fn_msdw, C_0);
        
        % finding eta_fit
        k = 1.3806503E-23;
        T = temperature;
        a = 0.5E-6;

        Dw = (1/4)*10.^Cw;
        eta_fit = (k*T)/(6*pi*a*Dw); % units = Pa*s
        
        % collect results and loads into structure
        msdFit_struct(i).eta_fit = eta_fit;
        
        % puts bead count into structure
        msdFit_struct(i).bead_count = data.beadcount_list(i);
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Plotting option
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if i == 40 
            
            figure;
            hold on;
            plot(tauData, msdData, 'r.');
            %plot(tauData,Fn_msd(C,tauData), 'r-')
            plot(tauData,Fn_msd(Cw,tauData), 'b-')
            ylim([-16,-10])
            xlim([-2,2])
            xlabel('log_{10}(\tau) [s]');
            ylabel('log_{10}(MSD) [m^2]');
            %legend({'MSD data', 'Unweighted fit', 'Weighted fit'},'location','SouthEast');
            legend({'MSD data', 'Weighted fit'},'location','SouthEast');
            well_num = num2str(i);
            title(['Well ' well_num])
            grid on;
            hold off
            pretty_plot;
            
        end
        
        
    end % if no data in the well
end % for loop


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Computing the percent error and loading into the msdFit_struct 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eta_water    = expected_values.eta_water;
eta_suc_2p0M = expected_values.eta_suc_2p0M;
eta_suc_2p5M = expected_values.eta_suc_2p5M;
eta_karo_suc = expected_values.eta_karo_suc;

for i = 1:96
   
   eta_fit = msdFit_struct(i).eta_fit;
    
   if i >= 1 && i <= 12 || i >= 49 && i <= 60
      eta_expected = eta_water; 
      percent_error = (eta_expected-eta_fit)/eta_expected;
   end
   if i >= 13 && i <= 24 || i >= 61 && i <= 72
      eta_expected = eta_suc_2p0M; 
      percent_error = (eta_expected-eta_fit)/eta_expected;
   end
   if i >= 25 && i <= 36 || i >= 73 && i <= 84
      eta_expected = eta_suc_2p5M; 
      percent_error = (eta_expected-eta_fit)/eta_expected;
   end
   if i >= 37 && i <= 48 || i >= 85 && i <= 96
      eta_expected = eta_karo_suc; 
      percent_error = (eta_expected-eta_fit)/eta_expected;
   end
    
   % collect results and loads into structure
   msdFit_struct(i).percent_error = percent_error;
end


end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Below were hard-coded expected values before the expected values were
%%% and necessary input structure for this function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%% CAP measurements from Jeremy

%eta_water    = 1.02E-3;     % mPa s   (actual value: 1.02 +/- 0.02)
%eta_suc_2p0M = 24.2E-3;     % mPa s   (actual value: 24.2 +/- 0.01)
%eta_suc_2p5M = 134.9E-3;    % mPa s   (actual value: 134.9 +/- 0.9)
%eta_karo_suc = 1342E-3;     % mPa s   (actual value: 1342 +/- 21)

% NEED TO CONFIRM WHY THIS NUMBERS ARE DIFF THAN ABOVE --> NUMS USED SIMS?
% eta_water    = 1.00E-3;     % mPa s   (actual value: 1.02 +/- 0.02)
% eta_suc_2p0M = 24.2E-3;     % mPa s   (actual value: 24.2 +/- 0.01)
% eta_suc_2p5M = 135E-3;    % mPa s   (actual value: 134.9 +/- 0.9)
% eta_karo_suc = 1340E-3;     % mPa s   (actual value: 1342 +/- 21)

%%% using viscosity of water from online source
% eta_water    = 0.000952;  --> What temperature is this at?

%%% using online source for water, 2M and 2.5M sucrose viscosity from model
% eta_water    = 0.000815; % Pa s at T = 303.15 K
% eta_suc_2p0M = 0.0171;   % Pa s  at T = 302.9 K
% eta_suc_2p5M = 0.0809;   % Pa s  at T = 302.9 K


   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Calculating percent error for 96-well plate of water only
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%    eta_fit = msdFit_struct(i).eta_fit;
%    
%    eta_expected = eta_water; 
%    percent_error = (eta_expected-eta_fit)/eta_expected;
%    
%    % collect results and loads into structure
%    msdFit_struct(i).percent_error = percent_error;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Calculating percent error for 96-well plate of 2.5 M sucrose only
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%    for i = 1:96
%        eta_fit = msdFit_struct(i).eta_fit;
% 
%        eta_expected = 0.0809;  % viscosity in Pa s from model for T = 302.9 K
%        percent_error = (eta_expected-eta_fit)/eta_expected;
% 
%        % collect results and loads into structure
%        msdFit_struct(i).percent_error = percent_error;
%    end

