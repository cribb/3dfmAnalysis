% wells = [15:22 27:34 39:46 51:58 63:70 75:82]';
wells = [15:22]';

rnd = rand(size(wells));
    
mylist = [rnd wells];

sortedlist = sortrows(mylist,1);

mywells = sortedlist(:,2);

