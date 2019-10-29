function outs = ba_normbymax(ins)
% BA_NORMBYMAX normalizes input such that the maximum value is one.
%

outs = ins(:) ./ max(ins(:));
end
