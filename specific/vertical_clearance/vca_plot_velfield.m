function v = vca_plot_velfield(evt_filename, video, gridXY)

if nargin < 1 || isempty(evt_filename) || isempty(dir(evt_filename))
    error('No file defined or file not found.');
end

if nargin < 2 || isempty(video)
    video.xDim = 1004;
    video.yDim = 1002;
    video.fps = 30;
    video.pixelsPerMicron = 4.84;
end    

if nargin < 3 || isempty(gridXY)
    NGridX = 45;
    NGridY = 45;
end

if length(gridXY(:)) == 1
    NGridX = gridXY;
    NGridY = gridXY;
elseif length(gridXY(:)) == 2
    NGridX = gridXY(1);
    NGridY = gridXY(2);
end

xgrid = (1:NGridX)*(video.xDim/NGridX/video.pixelsPerMicron);
ygrid = (1:NGridY)*(video.yDim/NGridY/video.pixelsPerMicron);

v = vel_field(evt_filename, NGridX, NGridY, video);

Xvel = reshape(v.sectorX, NGridX, NGridY);
Yvel = reshape(v.sectorY, NGridX, NGridY);

v.Vmag = sqrt(Xvel.^2 + Yvel.^2);
v.Vangle = atan2(Yvel, Xvel);

% figure; 
% surf(ygrid(:), xgrid(:), v.Vmag);
% colormap(hot);
% xlabel('X \mum')
% ylabel('Y \mum')
% zlabel('vel. [\mum/s]');
% pretty_plot;

figure; 
imagesc(xgrid, ygrid, v.Vmag'); 
colormap(hot);
xlabel('\mum')
ylabel('\mum')
title('Vel. [\mum/s]');
pretty_plot;
set(gca, 'YDir', 'normal');
cb = colorbar;

% cb_label = get(cb, 'TickLabels');
% for k = 1:length(cb_label)
%     cb_new{k,1} = ['10^{', cb_label{k}, '}']; 
% end
% set(cb, 'TickLabels', cb_new);



figure; 
ksdensity(v.Vmag(v.Vmag ~= 0)); legend('30^o');
legend(evt_filename, 'Interpreter', 'none');
xlabel('V_{mag} [\mum/s]');
ylabel('ksdensity');
grid on;

figure; 
ksdensity(v.Vangle(v.Vmag ~= 0)); legend('30^o');
legend(evt_filename, 'Interpreter', 'none');
xlabel('V_{angle} [\mum/s]');
ylabel('ksdensity');
xlim([-5*pi/4,5*pi/4])
set(gca, 'XTick', [-pi, -pi/2, 0, pi/2, pi])
set(gca, 'XTickLabel', {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'})
grid on;

figure;
quiver(v.xPosVal,v.yPosVal,v.sectorX,v.sectorY,0);
title(evt_filename, 'Interpreter', 'none');
% set(gca,'YDir','reverse'); 
xlim([0 video.xDim]);
ylim([0 video.yDim]);



return
