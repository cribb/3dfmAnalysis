function v = sawalk(number_of_steps, p, dim)

sizegrid = number_of_steps*2;
grid = zeros(sizegrid, sizegrid, sizegrid);
halfgrid = floor(number_of_steps);
grid(halfgrid, halfgrid, halfgrid) = 1;

% randomize state of random number generator
rand('state',sum(10000*clock))
rnd = rand(number_of_steps,2);
dimension = ceil(rnd(:,1)*3);
direction = ceil(rnd(:,2)*3)-2;

rnd = [dimension direction];

steps = zeros(size(rnd,1),dim);

for k = 1:length(steps)
 steps(k,dimension(k)) = direction(k);
end


% idx = find(rnd < p);
% steps(idx,active_dim(idx)) = -1;
% 
% idx = find(rnd >= p & rnd <= 2*p);
% steps(idx,active_dim(idx)) = 0;
% 
% idx = find(rnd >= 2*p);
% steps(idx,active_dim(idx)) = 1;

steps = reshape(steps, length(steps)/dim, dim);

path = zeros(size(steps));
count = 0;
collisions = 0;
k=2;
while k <= number_of_steps

    current_step_location = sum(steps(1:k,:)); 
    
    if grid(current_step_location+halfgrid+1)
        % reprocess new step location
        
%         disp(['k=' num2str(k) '  collision']);
        collisions = collisions + 1;
        newrnd = rand(dim,1);
        idx = find(newrnd < p);
        newstep(idx) = -1;
        idx = find(newrnd > p);
        newstep(idx) = 1;
        steps(k,:) = newstep;
        
    else
        path(k,:) = path(k-1,:) + steps(k-1,:);
        grid(path(k,:)+halfgrid+1) = 1;
%         fprintf('k=%i\n', k);
        k=k+1;
    end

    count = count + 1;
end

count
collisions
collisions/count

v=path;

