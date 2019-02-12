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
elseif length(gridXY(:) == 2)
    NGridX = gridXY(1);
    NGridY = gridXY(2);
end

xgrid = (1:NGridX)*(video.xDim/NGridX/video.pixelsPerMicron);
ygrid = (1:NGridY)*(video.yDim/NGridY/video.pixelsPerMicron);

foo = vel_field(evt_filename, NGridX, NGridY, video);

Xvel = reshape(foo.sectorX, NGridX, NGridY);
Yvel = reshape(foo.sectorY, NGridX, NGridY);
Vmag = sqrt(Xvel.^2 + Yvel.^2);

% figure; 
% surf(xgrid, ygrid, Vmag);
% colormap(hot);
% xlabel('X \mum')
% ylabel('Y \mum')
% zlabel('vel. [\mum/s]');
% pretty_plot;

figure; 
imagesc(xgrid, ygrid, Vmag'); 
colormap(hot);
xlabel('\mum')
ylabel('\mum')
title('Vel. [\mum/s]');
pretty_plot;

cb = colorbar;
% cb_label = get(cb, 'TickLabels');
% for k = 1:length(cb_label)
%     cb_new{k,1} = ['10^{', cb_label{k}, '}']; 
% end
% set(cb, 'TickLabels', cb_new);


plot_vel_field(foo, video);

v = foo;

return
