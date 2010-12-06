function v = dmbr_direct_moduli(t, J, J0, eta, dpoints, report)

%  moduli.m
%
% http://www.pcf.leeds.ac.uk/research/highlight/view/4
%
% Polymer & Complex Fluids Group
% School of Physics & Astronomy
% University of Leeds
%
% This program converts compliance measurements into storage and loss
% moduli, using the method described by 
% R M L Evans, Manlio Tassieri, Dietmar Auhl and Thomas A Waigh in 
% Phys. Rev. E 80, 012501 (2009).
%
% Coded by Chirag Kalelkar, Complex Fluids and Polymer Engineering Group,
% National Chemical Laboratory, Pune, India,
% Modified from code by David Pearce, University of Manchester, U.K.
% Edited by R M L Evans, University of Leeds, U.K.
% 
% Inputs:
%   J = compliance data (column vector)
%   t = time data (column vector)
%   eta = the long-time viscosity = reciprocal of gradient of asymptote of J(t).
%   J0 = value of compliance extrapolated to time t=0.
%   dpoints = number of output points required.
%   maxfreq = upper limit of frequency range to output.
%             Should usually set this to 1/t(1).
% 
%   N.B. The user must estimate eta and J0 from the data,
%   since *all* automated extrapolation procedures are flawed.
% 
% Output:
%   GData(frequency, G', G")


% close all;


% *************************************
% *** Edit the following two lines. ***

% J0 = 1.58;    
% eta = 0.721;  

% *************************************

% Establish empty data structure to speed up computation
GData = zeros(dpoints,3);
maxfreq = 1/2 * 1 ./ mean(diff(t));
% Valid frequency range is from 1/tmax to maxfreq

if t(1) == 0
    t = t(2:end);
    J = J(2:end);
end
    
frange = logspace(log10(1/t(length(t))),log10(maxfreq),dpoints);

% Calculate formula across frequency range
for ww = 1:dpoints
    w = frange(ww);
    GStar = 1i*w./(1i*w*J0 + (1-exp(-1i*w*t(1)))*(J(1)-J0)/t(1) + exp(-1i*w*t(size(t,1)))/eta + sum(diff(J)./diff(t).*(exp(-1i*w*(t(1:(size(t)-1))))-exp(-1i*w*(t(2:size(t)))))));
    
    A = 1i*w;
    B1= 1i*w*J0;
    B2= (1-exp(-1i*w*t(1)))*(J(1)-J0)/t(1);
    B3= exp(-1i*w*t(size(t,1)))/eta;
    B4= sum(diff(J)./diff(t).*(exp(-1i*w*(t(1:(size(t)-1))))-exp(-1i*w*(t(2:size(t))))));
    
    GStar = A / (B1 + B2 + B3 + B4);
    
    GData(ww,:) = [w real(GStar) imag(GStar)];
end


if strcmp(report,'y') || isempty(report)
    % Plot the moduli
    pos2 = find(GData(:,2) > 0);
    pos3 = find(GData(:,3) > 0);
    
    figure;
    loglog(GData(pos2,1),GData(pos2,2),'b.-');
    hold on
    loglog(GData(pos3,1),GData(pos3,3),'r.-');
    legend('G''','G''''','Location','NorthWest');
    xlabel('\omega [s^{-1}]');
    ylabel('Moduli [Pa]');
end

v = GData;

%Can superpose frequency sweep data if desired
%plot(freq,gprime,'.-');
%plot(freq,gdprime,'.-r');
