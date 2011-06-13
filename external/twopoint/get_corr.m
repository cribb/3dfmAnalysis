function [bres] = get_corr(d, lbinparams, dt, dim)
% calculates 'brownian correlation' components for track data....
% NOTE: d is original tracking data, here 'time'  is in the TIME column)
% d: original data (posstot)
% lbinparams: params for logspaced r
%       lmin: logarithmic minimum r
%       lmax: logarithmic maximum r
%       lrbinsize: bin size in logarithmic r
%       nbins: number of bins


% unpacking lbinparams
lmin      = lbinparams(1);
lmax      = lbinparams(2);
lrbinsize = lbinparams(3);
nbins     = lbinparams(4);

% get the 'r' ranges (squared).
rminsq = exp(2*lmin);
rmaxsq = exp(2*lmax);

% declare some arrays
bres = zeros((2*dim)+1,nbins);
ncol = size(d, 2);
nid  = max(d(ncol));

% column ID's of d (posstot)
ID   = ncol;
TIME = ncol - 1;
X    = 1;
Y    = 2;
Z    = 3;
SX   = dim + 1;
SY   = dim + 2;
SZ   = dim + 3;


% get the rows, we do all for dt le 3, and 'triple count' for bigger dts.
% Shifts data by dt (a single value since get_corr is called in a loop for
% all dt. dt measured in frame rates as in time, so this is a lagtime
sd = circshift(d,[-dt,0]);

if dt <= 3
    
    % find all that: time t and time shifted by dt is equal to dt
    %                neither position (t and shifted by dt) is 0 (?)
    %                the bead id for t and shifted by t is the same
    w = find( (              d(:,X)    ~=  0) & ...             % where x doesn't equal zero
              ( sd(:,X)                ~=  0) & ...             % where shifted x doesn't equal zero
              ( sd(:,ID)   - d(:,ID)   ==  0) & ...             % where the bead ID is the same for shifted and nonshifted
              ( sd(:,TIME) - d(:,TIME) == dt) );                % where the difference in shifted time and time is dt (eliminates the bottom of the shift which is meaningless data)
    
    nw = length(w);

else

    % find all that: time t and time shifted by dt is equal to dt
    %                neither position (t and shifted by dt) is 0 (?)
    %                the bead id for t and shifted by t is the same
    % with added 
    w = find( (             d(:,X)     ~=  0) & ...  % only where x's ~= 0
              (sd(:,X)                 ~=  0) & ...  % only where shifted x's ~= 0
              (sd(:,ID)   - d(:,ID)    ==  0) & ...  % only comparable bead IDs
              (sd(:,TIME) - d(:,TIME)  == dt) & ...  % only at time steps == dt
              ( ( mod(d(:,TIME),dt) ==                 1 ) | ...        % ??? removes unimportant data from circshift???
                ( mod(d(:,TIME),dt) == floor(dt/3)   + 1 ) | ...
                ( mod(d(:,TIME),dt) == floor(2*dt/3) + 1 )   ) );
            
    nw=length(w);

end


if nw <= 1  % -------------------------- ERW
    warning('Not enough data for this dataset.  Just passing through.');
    return;
end


% make up the data xs(1:dim) is the position at t of all bead which are 
% there at t + dt too and xs(dim+1:2*dim) is the position of those beads 
% at t + dt
xs = zeros(nw,2*dim);
xs(:,1:dim) = d(w,1:dim);
xs(:,dim+1:2*dim) = sd(w,1:dim);


% get the time and id info
ti = d(w,TIME);
id = d(w,ID);

% sort the data by time
[~,s] = sort(ti);
xs = xs(s,:);               
ti = ti(s);
id = id(s);


% get the indices of the unique *times*
[~,u] = unique(ti);
ntimes = length(u);
u = u';
u = [0,u];

% get the maximum number of beads in one frame pair
su = circshift(u,[0,-1]);
maxn = max( su(1:ntimes) - u(1:ntimes) );
%maxn is a single number

maxlist = maxn^2/2;

% using maxn to adjust the number of entries reported (for speed)
nreport = 500;
if maxn > 100, nreport = 250; end
if maxn > 200, nreport = 50; end
if maxn > 500, nreport = 10; end

% define a triangular raster scan list
[bbmat bamat] = meshgrid(1:maxn);

w = find(bbmat > bamat); 
nw0 = length(w);

% these vectors will contain respectively 1 1 2 1 2 3 ...
% and 2 3 3 4 4 4 .... so that they can be use as indices
% to do pairs: 1&2, 1&3, 2&3, 1&4...
if (nw0 > 0)
    bamat = bamat(w);
    bbmat = bbmat(w);
end

% define the scratchpad (list), 2e4 element lists sort the fastest
if maxlist > 2e4, 
    buf = maxlist; 
else
    buf = 2e4;
end  

list = zeros(dim+1,buf);

% loop over the times
point = 0;
for i = 1:ntimes

    % get the relevant data for the ith time. (all the xy positions at
    % ith time (first dim columns), and at ith time + dt (last dim columns)
    lxs = xs( u(i)+1 : u(i+1), : );
    
    ngood = length(lxs(:,1));

    % we should check!
    if ngood > 1   

        % fast N^2 distance calculator, inspired by 'track'
        ntri = ngood*(ngood-1)/2;

        amat = bamat(1:ntri);
        bmat = bbmat(1:ntri);

        % calculate the distance squared between 1&2, 1&3, 2&3,... 
        rsq = sum( (lxs(amat,1:dim)-lxs(bmat,1:dim)).^2 ,2);   

        w = find((rsq < rmaxsq) & (rsq > rminsq));
        nok = length(w);

        if nok > 0

            % calculate the sep. vectors
            r   = sqrt(rsq(w));         

            % distance between beads a & b at t=i (for binning)
            amatw = amat(w);
            bmatw = bmat(w);

            % distance in x & y between a & b at t=i
            rx  = lxs(amatw,X) - lxs(bmatw,X);  
            ry  = lxs(amatw,Y) - lxs(bmatw,Y);

            % position in x & y of a at t=i
            xa1 = lxs(amatw,X);                 
            ya1 = lxs(amatw,Y);

            % position in x & y of a at t=i+dt
            xa2 = lxs(amatw,SX);             
            ya2 = lxs(amatw,SY);

            % position in x & y of b at t=i                
            xb1 = lxs(bmatw,X);
            yb1 = lxs(bmatw,Y);

            % position in x & y of b at t=i+dt                
            xb2 = lxs(bmatw,SX);
            yb2 = lxs(bmatw,SY);

            % displacement of a in x & y between t=i and t=i+dt
            dxa = xa2 - xa1;                    
            dya = ya2 - ya1;

            % displacement of b in x & y between t=i and t=i+dt
            dxb = xb2 - xb1;
            dyb = yb2 - yb1;

            if dim == 2

                % calculate the longitudinal part
                rand('state', sum(100*clock));

                % randomize-- ran is 2 "abutting" vectors of 1's and -1's
                ran = 1 - 2 * (rand(nok,2) > 0.5);  
                
                
                % UNIT VECTORS
                
                % unit vector r1 +- the x component of unit vector
                % between a and b at t=i
                nx  =  rx.*ran(:,1)./r;      
                ny  =  ry.*ran(:,1)./r;

                % calculate the ortho unit vector for the transverse part:
                % By switching the y->x and x->-y we get perp vector.
                px  =  ny.*ran(:,2);        
                py  = -nx.*ran(:,2);

                
                % DISPLACEMENTS
                
                % component of displacement of a dotted to unit vector 
                % above times disp of b so "ran" in effect randomizes
                % whether r is from a to b or b to a. I guess that
                % helps with numerical rounding errors.
                ddl = ((dxa.*nx)+(dya.*ny)).*((dxb.*nx)+(dyb.*ny)); 

                % same dot product, but perp.
                ddt = ((dxa.*px)+(dya.*py)).*((dxb.*px)+(dyb.*py)); 

                
                % add to the list
                list(1,point+1:point+nok) = r;
                list(2,point+1:point+nok) = ddl;
                list(3,point+1:point+nok) = ddt;
                point = point+nok;
                
            end
            
        end
    end

    % do the running totals if the buffer gets full
    if point > (buf-maxlist)
        bres = bres + laccumulate(list(:,1:point),lbinparams,dim);
        point=0;
    end

    if mod(round(i),nreport) == 0
        disp([num2str(round(i)),'   ', ...
              num2str(ntimes)  ,'   ', ...
              num2str(sum(bres(2*dim+1,:))+point-1)]);
    end

end

% finish the running totals
if point > 0
    bres = bres + laccumulate(list(:,1:point),lbinparams,dim);
end

disp( [ num2str(round(i)),'   ', ...
        num2str(ntimes)  ,'   ', ...
        num2str(sum(bres(2*dim+1,:)))]);

return;
