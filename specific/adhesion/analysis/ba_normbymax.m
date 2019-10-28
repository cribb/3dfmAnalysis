function outs = ba_normbymax(ins)
   outs = ins(:) ./ max(ins(:));
end
