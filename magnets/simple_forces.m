function force = simple_forces(file, frame_rate, viscosity, radius);


d = load_video_tracking(file,frame_rate,[],[],'rectangle','m',0.0764);


x = d.video.x%(1:25);
y = d.video.y%(1:25);

radial = magnitude(x, y);

velocity = diff(radial) / (1/frame_rate);

force = 6 * pi * viscosity * radius * velocity;
time = 0 : 1/frame_rate : (length(x)-1)/frame_rate;

figure(1);
plot(d.video.x*1e6, d.video.y*1e6);
title(['xy for ' file]);
xlabel('microns');
ylabel('microns');

figure(2);
plot(time,radial*1e6);
title(['radial distance for ' file]);
xlabel('time (sec)');
ylabel('distance (um)');

figure(3);
plot(time(1:end-1), force*1e12);
title(['force for ' file]);
xlabel('time (sec)');
ylabel('force (pN)');

