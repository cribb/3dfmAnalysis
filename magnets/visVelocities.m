function varargout = visVelocities(data,mode,threshold)
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

% Last Modified : 05 January 04 by kd- changed the colormap type to "HOT"

if nargin < 3
    threshold = 0; %no threshold applied
end
if nargin < 2
    mode = 'both';
end

radias = 100; %draw a sphere of 50 micron radias
[ox,oy,oz] = sphere(30);
x = ox*radias; y = oy*radias; z = oz*radias;
svec = size(x);
colr(1:svec(1,1),1:svec(1,2)) = 0;
max_mag = 0;
color.num(1:svec(1,1),1:svec(1,2)) = 0;
color.contri(1:svec(1,1),1:svec(1,2)) = 0;
j = 0;
for i = 1:length(data.velx)
    j = j+ 1;
    dir3d = [data.velx(i,1), data.vely(i,1), data.velz(i,1)];
    mag = sqrt(dir3d*dir3d');
    max_mag = max(max_mag,mag);
    if(~mag)
        j = j-1;
        continue;
    end
    
    unit3d = dir3d/mag;
    
    data.origx(j,1) = unit3d(1,1)*radias;
    data.origy(j,1) = unit3d(1,2)*radias;
    data.origz(j,1) = unit3d(1,3)*radias;    

    if (strcmpi(mode,'colors') | strcmpi(mode,'both'))
        [miniz, zind] = min(abs(oz(:,1) - unit3d(1,3)));
        latind = zind(1,1);    
        [minix, xind] = min(abs(ox(latind,:) - unit3d(1,1)));
        minix = minix*1.01;
        tempa = find(abs(ox(latind,:)- unit3d(1,1)) <= minix);
        [miniy, yind] = min(abs(oy(latind,tempa(1,:)) - unit3d(1,2)));
        miniy = miniy*1.01;
        tempb = find(abs(oy(latind,tempa(1,:)) - unit3d(1,2)) <= miniy);
        longind = tempa(1,tempb(1,1));
        
        color_contri = mag;
        color.contri(latind,longind) = color.contri(latind,longind) + color_contri;
        color.num(latind,longind) = color.num(latind,longind) + 1;
    end
end
scale = radias/max_mag;
pole_length = 2*scale*max_mag;
max_colr = 0;

%this nested loops calculate average color for each bin 
% and maximum average color among all bins
for(i = 1:svec(1,1))
    for j = 1:svec(1,2)
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
    for i = 1:svec(1,1)
        for j = 1:svec(1,2)
            if(colr(i,j) < max_colr*threshold/100)
                colr(i,j) = 0;
            end
        end
    end
end
p(1,:) = [-pole_length, 0, pole_length];
p(2,:) = [pole_length, 0, pole_length];
p(3,:) = [0, -pole_length, -pole_length];
p(4,:) = [0, pole_length, -pole_length];

if (strcmpi(mode,'colors') | strcmpi(mode,'both'))
    %get rid of the patch between long180 and long0
%---------------------------------------------------
    s = size(colr);
    nlong = s(1,2);
    for k = 1:s(1,1)
        total_colr = color.contri(k,1) + color.contri(k,nlong);
        total_num = (color.num(k,1) + color.num(k,nlong)); 
        if(total_num)
            colr(k,nlong) = total_colr/total_num; 
        else
            colr(k,nlong) = 0;
        end
        colr(k,1) = colr(k,nlong);
    end
%---------------------------------------------------
    figure
	quiver3([0 0 0 0]',[0 0 0 0]',[0 0 0 0]',p(:,1), p(:,2), p(:,3),1,'.','r');
	hold on
	surf(x,y,z,colr);
    colormap hot;
    shading interp;
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
    surf(x,y,z); colormap white;
    hold on
    %velocity vector hairs
    
	for j=1:length(data.origx)
		quiver3(data.origx(j,1), data.origy(j,1), data.origz(j,1), data.velx(j,1)*scale, data.vely(j,1)*scale, data.velz(j,1)*scale, 0,'.','r');
% 		pause(.5)
	end
    %Put poles
    quiver3([0 0 0 0]',[0 0 0 0]',[0 0 0 0]',p(:,1), p(:,2), p(:,3),1,'.','b');
	set(gca,'Fontsize',12);
	xlabel('X axes');
	ylabel('Y axes');
	zlabel('Z axes');
	axis equal;
end
