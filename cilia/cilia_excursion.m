clear all;
close all;
clc;

w = 0.2; % seconds (window length)
fs = 1000; % sampling frequency
res = 1; % psd resolution

x = 1;
y = 2;
z = 3;

d = load_matlab_tracking('20020730133509[1].tracking.log.stage.mat',1000);
time = d.stage.ts;
pos  = [d.stage.xs d.stage.ys d.stage.zs];


% make temporal stacks by partitioning datasets by window
num_elements = w * fs;
endpoint = floor(length(pos) / num_elements); %can't use partial window
t = (1:endpoint) * w; % transform time from window_id# back to time

for stack_id = 1:endpoint;;
    range = num_elements*(stack_id-1)+1:num_elements*stack_id;
    time_stack(:,:,stack_id) = pos(range,:);
end

x_stack = squeeze(time_stack(:,x,:));
x_excursions = max(x_stack) - min(x_stack);
x_means = mean(x_stack,1);

y_stack = squeeze(time_stack(:,y,:));
y_excursions = max(y_stack) - min(y_stack);
y_means = mean(y_stack,1);

z_stack = squeeze(time_stack(:,z,:));
z_excursions = max(z_stack) - min(z_stack);
z_means = mean(z_stack,1);

% Magnitude of excursions
excursion_mags = sqrt(x_excursions.^2 + y_excursions.^2 + z_excursions.^2);

figure(1);
subplot(2,1,1);
plot(t,x_excursions);
title('Excursion of Cilia in x')
xlabel('time (seconds)');
ylabel('excursion length (um)');

figure(1);
subplot(2,1,2);
plot(t,x_means);
title('Mean Position, x');
xlabel('time (seconds)');
ylabel('mean');

figure(2);
subplot(2,1,1);
plot(t,y_excursions);
title('Excursion of Cilia in y')
xlabel('time (seconds)');
ylabel('excursion length (um)');

figure(2);
subplot(2,1,2);
plot(t,y_means);
title('Mean Position, x');
xlabel('time (seconds)');
ylabel('mean');

figure(3);
subplot(2,1,1);
plot(t,z_excursions);
title('Excursion of Cilia in z')
xlabel('time (seconds)');
ylabel('excursion length (um)');

figure(3);
subplot(2,1,2);
plot(t,z_means);
title('Mean Position, z');
xlabel('time (seconds)');
ylabel('mean');

figure(4);
plot(t, excursion_mags);
title('xyz excursion magnitudes');
xlabel('time (seconds)');
ylabel('magnitude (um)');