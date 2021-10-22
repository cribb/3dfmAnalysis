function v = stderr(X, flag, dim, nanflag)

if nargin < 4 || isempty(nanflag)
    nanflag = 'includenan';
else
    nanflag = 'omitnan';
end

if nargin < 3 || isempty(dim)
    dim = 1;
end

if nargin < 2 || isempty(flag)
    flag = [];
%     dim = 1;
end

if (length(size(X)) == 2)  && (size(X,1) == 1)
    X = X(:);
end

%     v = std(X, flag, dim, nanflag) ./ sqrt(size(X,dim));

    sd = std(X, flag, dim, nanflag);
    
    if contains(nanflag,'includenan')
        sz = size(X,dim);
    else
        sz = sum(~isnan(X),dim, nanflag);
    end
    
    v = sd ./ sqrt(sz);
return;

