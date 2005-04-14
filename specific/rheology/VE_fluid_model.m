function [t, ct, pulse] = VE_fluid_model(K, D1, D2);

% K  = eps;
% D1 = 1;
% D2 = eps;

warning off MATLAB:divideByZero

t = 0:0.005:50;

t1 = 10;
t2 = 20;
t3 = 30;
t4 = 40;

pulse = heavi(t, t1) - heavi(t,t2)  + heavi(t,t3) - heavi(t,t4);

ct = (1/K + (t-t1)/D2 - 1/K*exp(-K*(t-t1)/D1)).*heavi(t,t1) - ...
     (1/K + (t-t2)/D2 - 1/K*exp(-K*(t-t2)/D1)).*heavi(t,t2) + ...
     (1/K + (t-t3)/D2 - 1/K*exp(-K*(t-t3)/D1)).*heavi(t,t3) - ...
     (1/K + (t-t4)/D2 - 1/K*exp(-K*(t-t4)/D1)).*heavi(t,t4);

% figure(2);
% subplot(2,1,1);
% plot(t, ct);
% xlabel('time (sec)');
% ylabel('displacement (microns)');
% title(['Step Response (D1 = ' num2str(D1) ', D2 = ' num2str(D2) ', K = ' num2str(K) ')']);
% pretty_plot;
% 
% subplot(2,1,2);
% plot(t, pulse);
% axis([min(t), max(t), -1, 2]);
% xlabel('time (sec)');
% ylabel('force, normalized units');
% title('Input Pulse');
% pretty_plot;
