
[rows cols pages] = size(data);
count = 1;

for a = 1:rows
    fprintf('a = %d\n', a);
    for b = 1:cols
        for c = 1:pages
            newdata(count,:) = [a b c data(a,b,c)];
            count = count + 1;    
        end
    end
end