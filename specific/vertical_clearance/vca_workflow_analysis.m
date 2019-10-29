% function outs = vca_workflow_analysis(trackfile, vidstruct)

trackfile = '01_RightSide_tilt30_ciliaheight_8msEXP_90s_duration.vrpn.evt.mat';
NX = 50;
NY = 40;

vidstruct.pixelsPerMicron = 2.89;
vidstruct.xDim = 2048;
vidstruct.yDim = 1536;
vidstruct.fps = 120;

v = vca_plot_velfield(trackfile, vidstruct, [NX NY]);
v.Vmag = sqrt(v.sectorX(:).^2 + v.sectorY(:).^2);
v.Vangle = atan2(v.sectorY(:), v.sectorX(:));

figure; 
ksdensity(v.Vmag(v.Vmag ~= 0)); legend('30^o');
xlabel('V_{mag} [\mum/s]');
ylabel('ksdensity');

figure; 
ksdensity(v.Vangle(v.Vmag ~= 0)); legend('30^o');
xlabel('V_{angle} [\mum/s]');
ylabel('ksdensity');
xlim([-5*pi/4,5*pi/4])
set(gca, 'XTick', [-pi, -pi/2, 0, pi/2, pi])
set(gca, 'XTickLabel', {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'})
grid on;






