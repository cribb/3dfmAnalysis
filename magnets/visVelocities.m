function varargout = visVelocities(data,poles,mode,threshold)
% varargout = visVelocities(data,mode,threshold)
% 3DFM FUNCTION
% varargout = none as of 5th Jan 04
% data = velocity data structure with fields 'velx' 'vely' and 'velz'
% mode = visualization mode : ['colors','hairs','both'] default 'both'
% threshold = % of maximum velocity, all velocities below which are considered noise
%               Threshold is only applied in 'colors' mode as of 5th Jan 04
% This function is written specifically for lissajous experiments but it can be used 
% for the purpose of visualizing directionality and magnitude of the force. The 'colors'
% mode plots a sphere with hot colormap. The color of particular point corresponds to the 
% average velocity at that point. The 'hairs' mode plots a sphere with hairs on it. Each 
% hair corresponds to a velocity point in that direction with magnitude proportional to the
% length of the hair.

% Last Modified : 10 January 04 by kd- changed the colormap type to "HOT"
% 06/10/04: changed the visualization for 'colors' mode: using sphere_tri to tesselate the sphere with triangles

if nargin < 4
    threshold = 0; %no threshold applied
end
if nargin < 3
    mode = 'both';
end

radias = 100; %draw a sphere of 50 micron radias
[ox,oy,oz] = sphere(29);
x = ox*radias; y = oy*radias; z = oz*radias;
svec = size(x);
% colr(1:svec(1,1),1:svec(1,2)) = 0;
max_mag = 0;
% color.num(1:svec(1,1),1:svec(1,2)) = 0;
% color.contri(1:svec(1,1),1:svec(1,2)) = 0;
j = 0;
% sphere_tri is an opensource matlab tool that tesselates the sphere of
% given radius with equilateral triangles. It does this by starting with an
% icosahedron and then breaks up each triangle into four equilateral small
% triangles. Does this breaking for the times as specified in second
% arguement
FV = sphere_tri('ico',4,radias,0);
svec2 = size(FV.vertices);
% 'color' stores the total sum of the length of velocity vectors that fall
% in to particular bin, while 'colr' saves the average velocity.
color.num(1:svec2(1,1),1) = 0;
color.contri(1:svec2(1,1),1) = 0;
colr(1:svec2(1,1),1) = 0;
ibad = 0;
for i = 1:length(data.velx)
    j = j + 1;
    dir3d = [data.velx(i,1), data.vely(i,1), data.velz(i,1)];
    mag = sqrt(dir3d*dir3d');
    max_mag = max(max_mag,mag);
    if(~mag) % if this is a zero velocity vector than discard it, because it creates empty spaces in sphere
        j = j-1;
        continue;
    end
    unit3d = dir3d/mag; %unit vector along the direction of this velocity
    
    data.origx(j,1) = unit3d(1,1)*radias; % used only for purpose of plotting hairs
    data.origy(j,1) = unit3d(1,2)*radias;
    data.origz(j,1) = unit3d(1,3)*radias;    
    color_contri = mag; %color contribution of this velocity to a particular bin

    if(strcmpi(mode,'colors') | strcmpi(mode,'both'))
        vertices = FV.vertices;
        face = FV.faces;
        % find the closest vertex to this velocity vector
        [m,index] = max(vertices(:,1).*unit3d(1) + vertices(:,2).*unit3d(2) + vertices(:,3).*unit3d(3));
        v(1,1:3) = vertices(index);
        ind(1) = index;
        % find the faces in which the above found vertex is involved
        [fi fj] = find(face == ind(1));
        face1 = face(fi,:); % the list of all faces found. 
        fverts = [face1(:,1); face1(:,2); face1(:,3)]; % list of all vertices needed to make face1
        %some vertices might be repeated in this list.
        fverts = sort(fverts);
        iclean = 0;
        % make a list of idices of all vertices involved in making the faces listed
        % in face1. include the ind(1) in the list also.
        for vind = 1:length(fverts)
               if(iclean <1);
                    iclean = iclean + 1;
                    cleanvert(iclean) = fverts(vind);
                else(fverts(vind) ~= cleanvert(iclean) | iclean < 1);
                    iclean = iclean + 1;
                    cleanvert(iclean) = fverts(vind);
                end
        end
        
        % dot product of all listed vertices in cleanvert with the current
        % velocity vector
        for iclean = 1:length(cleanvert)
            dotp(iclean) =  (vertices(cleanvert(iclean),1).*unit3d(1) + vertices(cleanvert(iclean),2).*unit3d(2) + vertices(cleanvert(iclean),3).*unit3d(3));
        end
        [sdotp idotp]=  sort(dotp);
        % There could be at most three vertices to which a vector can be at
        % equal distance. So we are interested in only three vertices from
        % the cleanvert which are closest to velocity vector.
        if (abs(sdotp(end) - sdotp(end-1) > 0.05*abs(sdotp(end))))  % if true, then there is no tie here. 
            color.contri(cleanvert(idotp(end)),1) = color.contri(cleanvert(idotp(end)),1) + color_contri;
            color.num(cleanvert(idotp(end)),1) = color.num(cleanvert(idotp(end)),1) + 1;
        elseif (abs(sdotp(end) - sdotp(end-2) > 0.05*abs(sdotp(end)))) % tie between only two vertices
            color.contri(cleanvert(idotp(end)),1) = color.contri(cleanvert(idotp(end)),1) + color_contri/2;
            color.num(cleanvert(idotp(end)),1) = color.num(cleanvert(idotp(end)),1) + 1;
            color.contri(cleanvert(idotp(end-1)),1) = color.contri(cleanvert(idotp(end-1)),1) + color_contri/2;
            color.num(cleanvert(idotp(end-1)),1) = color.num(cleanvert(idotp(end-1)),1) + 1;            
        else % tie between all three vertices
            color.contri(cleanvert(idotp(end)),1) = color.contri(cleanvert(idotp(end)),1) + color_contri/3;
            color.num(cleanvert(idotp(end)),1) = color.num(cleanvert(idotp(end)),1) + 1;
            color.contri(cleanvert(idotp(end-1)),1) = color.contri(cleanvert(idotp(end-1)),1) + color_contri/3;
            color.num(cleanvert(idotp(end-1)),1) = color.num(cleanvert(idotp(end-1)),1) + 1;
            color.contri(cleanvert(idotp(end-2)),1) = color.contri(cleanvert(idotp(end-2)),1) + color_contri/3;
            color.num(cleanvert(idotp(end-2)),1) = color.num(cleanvert(idotp(end-2)),1) + 1;
        end
    end
end
% total number of faces with zero color
totalblack = length(find(color.contri <= 0))
% total number of faces which none of the velocity vector fall into
totalnull = length(find(color.num <= 0))
scale = radias/max_mag;
if (strcmpi(mode,'colors') | strcmpi(mode,'both'))

    pole_length = 2*scale*max_mag;
    max_colr = 0;
    
    %this nested loops calculate average color for each bin 
    % and maximum average color among all bins
    for(i = 1:svec2(1,1))
        for j = 1:1
            if(color.num(i,j))
                colr(i,j) = color.contri(i,j)/color.num(i,j);
                max_colr = max(max_colr,colr(i,j));
            else
                colr(i,j) = 0;
            end
        end
    end
    
    %this nested loops set the colors below threshold to zero
    if(threshold)
        for i = 1:svec2(1,1)
            for j = 1:1
                if(colr(i,j) < max_colr*threshold/100)
                    colr(i,j) = 0;
                end
            end
        end
    end
% totalunder = length(find(colr <= 0))    
    figure
    subplot('position',[0.1 0.1 0.7 0.85]);
    hold on
    size(poles);
    Npoles = ans(1,1);
%     orig = zeros(Npoles,1);
%     quiver3(orig,orig,orig,poles(:,1), poles(:,2), poles(:,3),4,'.','r');
    for ipol = 1:Npoles
        line([0,poles(ipol,1)*3], [0,poles(ipol,2)*3], [0,poles(ipol,3)*3], 'LineWidth', 4, 'color', 'b')
    end
    FV.colr = colr;
	Hp = patch('faces',FV.faces,'vertices',FV.vertices,'FaceVertexCdata',FV.colr,...
    'facecolor','flat');
    colormap hot;
    shading interp;
    hold off
	set(gca,'Fontsize',12);
	xlabel('X axes');
	ylabel('Y axes');
	zlabel('Z axes');
	axis equal;
    
    % now show the colormap bar at the right hand side
    colorbar('vert');
%     subplot('position',[0.85 0.1 0.09 0.85] );
%     maxc = max(FV.colr);
%     minc = min(FV.colr);
%     rangec = maxc - minc;
%     py = minc:rangec/20:maxc;
%     px = 0:1/length(py):1-1/length(py);
%     for i = 1:length(py)
%         c(i,1:length(px)) = py(i);
%     end
%     pcolor(px,py,c);
%     colormap hot
%      shading interp
end

if (strcmpi(mode,'hairs') | strcmpi(mode,'both'))
	figure
    %background sphere
    surf(x,y,z); colormap white;
    hold on
    %velocity vector hairs
    
	for j=1:length(data.velx)
		quiver3(data.origx(j,1), data.origy(j,1), data.origz(j,1), data.velx(j,1)*scale, data.vely(j,1)*scale, data.velz(j,1)*scale, 0,'.','r');
%         C(j,1) = sqrt(data.velx(j,1).^2 + data.vely(j,1).^2 + data.velz(j,1).^2);
% 		pause(.5)
	end
%     scatter3(data.velx, data.vely, data.velz,100,C,'filled');
    %Put poles
    size(poles);
    Npoles = ans(1,1);
    orig = zeros(Npoles,1);
    quiver3(orig,orig,orig,poles(:,1), poles(:,2), poles(:,3),max_colr*2,'.','c');
%     colormap hot
	set(gca,'Fontsize',12);
    
	xlabel('X axes');
	ylabel('Y axes');
	zlabel('Z axes');
	axis equal;
    set(gca,'Color','k');
end
% keyboard