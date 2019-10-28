function Fid  = ba_makeFid(rngseed)

    if nargin < 1 || isempty(rngseed)
        rng('shuffle');
    else
        rng(rngseed);
    end

    Fid = randi(2^50,1,1);