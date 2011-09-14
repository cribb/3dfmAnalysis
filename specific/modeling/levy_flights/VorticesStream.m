function VorticesStream(vlx,vly,gamma,vortex_type,stream_option,save_option)
% VorticesStream  Generates vortical flow profiles
%
% VorticesStream will generate a vector field of vortices located at (vlx,vly).
% NOTE the type of vortex.  Irrotational vortices, a.k.a. free vortices, 
% are those in which fluid is drawn down a drain (tub, whirlpool).  The 
% other type, rotational vortices, are also called force vortices, which 
% occurs when the fluid just circulates.  The strength of each vortex 
% is encapulated within 'gamma' but is really the circulation strength in a
% irrotational vortex and the angular velocity in rotational.
%
% Usage:
%
% VorticesStream(vlx,vly,gamma,vortex_type,stream_option,save_option)
% 
% vlx:   vortex locations in x (default: 0)
% vly:   vortex locations in y (default: 0)
% gamma: vortex circulation for irrot., angular velocity in rot. (default: 1)
% vortexType: {'irrotational'} or 'rotational'
% stream_option: 'yes' or {'no'}, indicates whether to compute particule streams
% save_option: 'yes' or {'no'}, indicates whether to save particle streams to videofile.
%
% Example:  
% 
% [vlx,vly] = meshgrid(0:10:40, 0:10:40);
% VorticesStream(vlx,vly,[],'irrotational','yes','no');
%

%matlabpool(4);

if nargin < 1 || isempty(vlx)
    vlx = 0;
elseif size(vlx) ~= size(vly)
    error('Vortex locations must have the same number of X and Y values defined.');
end
    
if nargin < 2 || isempty(vly)
    vly = 0;
end

if nargin < 3 || isempty(gamma)
    gamma = ones(size(vlx));
end

if nargin < 4 || isempty(vortex_type)
    vortex_type = 'irrotational';
end

if nargin < 5 || isempty(stream_option)
    stream_option = 'no';
end

if nargin < 6 || isempty(save_option)
    save_option = 'no';
end

vlx = vlx(:);
vly = vly(:);
gamma = gamma(:);

% set up the grid
minx = min(vlx);
miny = min(vly);
maxx = max(vlx);
maxy = max(vly);
ranx = maxx - minx;
rany = maxy - miny;

if length(vlx) == 1
    ranx = 5 * gamma;
    minx = minx - ranx/2;
    maxx = maxx + ranx/2;
end

if length(vly) == 1
    rany = 5 * gamma;
    miny = miny - rany/2;
    maxy = maxy + rany/2;
end

bufx = ranx / 10; % a 10% buffer added to the boundary around the furthest points of interest
bufy = rany / 10;
gridx = ranx / 100;
gridy = rany / 100;

x_ = (minx - bufx) : gridx : (maxx+bufx);
y_ = (miny - bufy) : gridy : (maxy+bufy);

[x,y] = meshgrid(x_, y_);

[vx,vy] = vortex_vectors(x,y,vlx,vly,gamma,vortex_type);

h = figure;
quiver(x, y, vx, vy, 'Color', [0.7 0.7 0.7]);
xlim([(minx - bufx) (maxx+bufx)]);
ylim([(miny - bufy) (maxy+bufy)]);

if strfind(stream_option, 'yes');

    % Pick random starting locations for streamlines
    xs = x(1,sort(round(rand(1,10)*size(x,1))));
    ys = y(sort(round(rand(1,10)*size(x,1))),1);   

    str2 = stream2(x, y, vx, vy, xs(:), ys(:));
    istr2 = interpstreamspeed(x,y, vx, vy, str2, 5);

    %set(gca,'DrawMode','fast');

    streamparticlesARS(istr2, 15, 'animate', 10, 'frameRate', 10, ...
                           'ParticleAlignment', 'off', 'SaveOption', 'y');
end;
