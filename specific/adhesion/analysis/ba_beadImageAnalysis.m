function outs = ba_beadImageAnalysis(bigT, g)

    fooT = sortrows(bigT, {'BeadChemistry', 'Media', 'LastImageMax'});
    
    [g, grpT] = findgroups(fooT(:,{'BeadChemistry', 'Media'}));
    
    before = splitapply(@(x){sa_bead_image_maxlines(x)},fooT.FirstImage,g);
    after = splitapply(@(x){sa_bead_image_maxlines(x)},fooT.LastImage,g);

    outs = table(before,after);
end

function outs = sa_bead_image_maxlines(beadImage)
    
    foo = cellfun(@(x)max(x, [], 2), beadImage, 'UniformOutput', false);
    bah = cell2mat(cellfun(@length, foo, 'UniformOutput', false));
    
    outs = zeros(max(bah), length(foo));
    foo = transpose(foo);
    for k = 1 : length(foo)
       outs(1:bah(k),k) = cell2mat(foo(1,k));
    end
end