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
svec2 = size(FV.faces);
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
        % in face1. Exclude the ind(1) from the list though.
        for vind = 1:length(fverts)
            if (fverts(vind) ~= ind(1));
                if(iclean <1);
                    iclean = iclean + 1;
                    cleanvert(iclean) = fverts(vind);
                else(fverts(vind) ~= cleanvert(iclean) | iclean < 1);
                    iclean = iclean + 1;
                    cleanvert(iclean) = fverts(vind);
                end
            end
        end
        iclean = 1;
        % dot product of all listed vertices in cleanvert with the current
        % velocity vector
        dotp(iclean) =  (vertices(cleanvert(iclean),1).*unit3d(1) + vertices(cleanvert(iclean),2).*unit3d(2) + vertices(cleanvert(iclean),3).*unit3d(3));
        for iclean = 2:length(cleanvert)
            dotp(iclean) =  (vertices(cleanvert(iclean),1).*unit3d(1) + vertices(cleanvert(iclean),2).*unit3d(2) + vertices(cleanvert(iclean),3).*unit3d(3));
        end
        [sdotp idotp]=  sort(dotp);
        % check if the current velocity vector falls directly on some
        % vertex. If so, then distribute the intesity evenly among all
        % faces containing that vertex. If not, then search only in the cleanvertices 
        % for the closest two vertices to the current velocity vector. Those two vertices and ind(1) 
        % must make a face, if they don't consider that as an algorithmic
        % error and increment ibad count;
        if (range(dotp) < 0.01*dotp(1))  % the vector is at the center of hexagon /pentagon
            %distribute the intensity amonng all faces containing that
            %vertex equally. 
            for itemp = 1:length(fi)
                color.contri(fi(itemp),1) = color.contri(fi(itemp),1) + color_contri/length(fi);
                color.num(fi(itemp),1) = color.num(fi(itemp),1) + 1; 
            end
            clear itemp;
        else % the vector is not right-on the vertex, so find another two closest vertices
            ind(2) = cleanvert(idotp(end));
            ind(3) = cleanvert(idotp(end-1));            
%                     vertices(index,:) = [0 0 0];
%                     [m,index] = max(vertices(:,1).*unit3d(1) + vertices(:,2).*unit3d(2) + vertices(:,3)*unit3d(3));
%                     v(2,1:3) = vertices(index);
%                     ind(2) = index;
%                     vertices(index,:) = [0 0 0];
%                     [m,index] = max(vertices(:,1).*unit3d(1) + vertices(:,2).*unit3d(2) + vertices(:,3)*unit3d(3));
%                     v(3,1:3) = vertices(index);
%                     ind(3) = index;
%                     vertices(index,:) = [0 0 0];
% %             
% %                     [fi fj] = find(face == ind(1));
% %                     face1 = face(fi,:);
% %                         
            [fk fl] = find(face1 == ind(2));
            face2 = face1(fk,:);
            [fm fn]= find(face2 == ind(3));
            
            iface = fi(fk(fm)); 
            if isempty(iface)
                ibad = ibad + 1
            end
            
            color.contri(iface,1) = color.contri(iface,1) + color_contri;
            color.num(iface,1) = color.num(iface,1) + 1;           
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

%     %get rid of the patch between long180 and long0
% %---------------------------------------------------
%     s = size(colr);
%     nlong = s(1,2);
%     for k = 1:s(1,1)
%         total_colr = color.contri(k,1) + color.contri(k,nlong);
%         total_num = (color.num(k,1) + color.num(k,nlong)); 
%         if(total_num)
%             colr(k,nlong) = total_colr/total_num; 
%         else
%             colr(k,nlong) = 0;
%         end
%         colr(k,1) = colr(k,nlong);
%     end
%---------------------------------------------------
    figure
    hold on
    size(poles);
    Npoles = ans(1,1);
    orig = zeros(Npoles,1);
    quiver3(orig,orig,orig,poles(:,1), poles(:,2), poles(:,3),4,'.','c');

%     shading interp;
	Hp = patch('faces',FV.faces,'vertices',FV.vertices,'facevertexcdata',colr,...
    'facecolor','flat');
    colormap hot;
%     shading interp;
	
  	hold off
	set(gca,'Fontsize',12);
	xlabel('X axes');
	ylabel('Y axes');
	zlabel('Z axes');
	axis equal;
end

if (strcmpi(mode,'hairs') | strcmpi(mode,'both'))
	figure
    %background sphere
%     surf(x,y,z); colormap white;
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
    colormap hot
	set(gca,'Fontsize',12);
    
	xlabel('X axes');
	ylabel('Y axes');
	zlabel('Z axes');
	axis equal;
    set(gca,'Color','k');
end
% keyboard