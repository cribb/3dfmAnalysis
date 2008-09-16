function out = wfpoles_forces(vfcfile, report)
% 3DFM function  
% Magnetics 
% last modified 09/16/2008
%  
% This function computes 2d forces on beads in Newtonian fluid using Stokes
% drag.
%  
%  [out] = wfpoles_forces(vfcfile, report)
%   
%  where "out" is output data structure
%        "vfcfile" is the varforce calibration filename 
%        "report" is string 'y' or 'n' that plots figure (or not).
%   


% convenient labels for matrix columns
VOLTS = 1;
X = 2;
FX = 3;

% load in calibration file from varforce_analysis_gui
cal = load(vfcfile);

% extract relevant data and sort by applied voltage
dataout = [cal.forcecal.data.volts, cal.forcecal.data.xy(:,1), cal.forcecal.data.Fxy(:,1)];
dataout = sortrows(dataout,VOLTS);

% Extract out dependence of force on distance
tmp = sortrows(dataout, X);
sortx = tmp(:,X);
sortFx = tmp(:,FX);

% compute slope of distance dependence via linear fit
[P,S] = polyfit(sortx, sortFx, 1);
sortFx_fit = polyval(P, sortx);
fprintf('slope=%g, intercept=%g\n', P(2), P(1));

% compute average forces at each of the discrete voltages
voltlist = unique(dataout(:,VOLTS))';

count = 1;
for k = voltlist % for each voltage
    idx = find(dataout(:,VOLTS) == k);
    
    N = length(idx);
    v(count,:) = mean(dataout(idx, VOLTS));
    x(count,:) = mean(dataout(idx, X));
    Fx(count,:) = mean(dataout(idx, FX));
    stdx(count,:) = mean(dataout(idx, FX));
    errx(count,:) = stdx(count)/sqrt(N);
    
    count = count + 1;
end    
    
    % plot dependence of force on voltage
    figure; 
    errorbar(v, abs(Fx*1e12), abs(errx*1e12), abs(errx*1e12));
    xlabel('Volts');
    ylabel('Force [pN]');
    pretty_plot;
    
    
% setup outputs    
out.raw.voltage = dataout(:,VOLTS);
out.raw.x     = dataout(:,X);
out.raw.Fx    = dataout(:,FX);

out.voltdep.voltage = v;
out.voltdep.x       = x;
out.voltdep.Fx      = Fx;
out.voltdep.N       = N;
out.voltdep.stdx    = stdx;
out.voltdep.errx    = errx;

out.distdep.x  = sortx;
out.distdep.Fx = sortFx;
out.distdep.fit = P;

return;
