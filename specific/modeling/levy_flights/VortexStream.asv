% Example method for modeling the vortex vector field.  Outputs the model
% to a quiver plot and allows matlab to generate an animated figure, where 
% stream particles follow the vector field.

figure; 

gamma1 = 4;
gam1Pos = [0 0];

x1 = -5:0.1:5;
y1 = -5:0.1:5;

[x,y] = meshgrid(x1, y1);

r = sqrt((x - gam1Pos(1)).^2 + (y - gam1Pos(2)).^2);

theta1 = atan2((x-gam1Pos(1)), (y-gam1Pos(2)));

theta2 = theta1 + pi/2;

vel = gamma1./(2*pi*r);

vx = vel.*sin(theta2);
vy = vel.*cos(theta2);

% remove infinities and NaNs
id1 = isinf(abs(vx));   vx(id1) = 0;
id2 = isinf(abs(vy));   vy(id2) = 0;
id3 = isnan(vx);        vx(id3) = 0;
id4 = isnan(vy);        vy(id3) = 0;

quiver(x, y, vx, vy);
grid on;

xlim([-5 5])
ylim([-5 5])

str2 = stream2(x, y, vx, vy, x(:,6), y(:,1));


istr2 = interpstreamspeed(x,y, vx, vy, str2,.5);

set(gca,'DrawMode','fast');

streamparticles(istr2, 8, 'animate', 10, 'frameRate', 30, ...
                       'ParticleAlignment', 'on');