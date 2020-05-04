function Fid  = evt_makeFid(rngseed)
% BA_MAKEFID generates unique (enough) File IDs for an adhesion assay run.
%

    if nargin < 1 || isempty(rngseed)
        pause(0.05);
        rng('shuffle');
    else
        rng(rngseed);
    end

    Fid = randi(2^50,1,1);