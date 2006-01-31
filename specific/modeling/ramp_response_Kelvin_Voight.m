close all;
clear all;
clc; 

tic;

K = [3:3:60]; D = [3:3:60];
clr = 'rgbkmcy';
t = 0 : 0.001 : 1;

for d = 1 : length(D)
	for k = 1 : length(K)
		a = -K(k)/D(d);
		ct = (-a*t-1+exp(a*t))/(D(d)*a^2);
	
% 		figure(1); 
% 		hold on; 
% 		plot(t, ct, clr(mod(k,7)+1));
% 		xlabel('time [s]');
% 		ylabel('distance [m]');
% 		title(['K=' num2str(K(k)) 'D=' num2str(D(d))]);
% 		hold off;
	
        idx = find(t == 1);
        Kslice(k) = ct(idx);
        slice(d,k) = ct(idx);
	end;
    Dslice(d) = ct(idx);
end;

figure(2);
plot(K, Kslice, D, Dslice);
xlabel('model constant, K [N/m] or D [N s m^{-1}]');
ylabel('trans. distance [m] in 1 [s]');
legend('K, D=1', 'D, K=1');
pretty_plot;

figure(3);
plot(D,Dslice);
xlabel('dashpot drag, D [N s m^{-1}]');
ylabel('trans. distance [m] in 1 [s]');
pretty_plot;

figure(4);
imagesc(D,K,slice);
title('Translated distance in 1 sec');
xlabel('dashpot drag, D [N s m^{-1}]');
ylabel('spring constant, K [N/m]');
colormap(hot);
colorbar;
pretty_plot;

figure(5);
surf(D,K,slice);
title('Translated distance in 1 sec');
xlabel('dashpot drag, D [N s m^{-1}]');
ylabel('spring constant, K [N/m]');
colormap(hot);
colorbar;
pretty_plot;

toc;