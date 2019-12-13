function manual_colorbar(datarange, labels, mycolormap, orientation)

if nargin < 2 || isempty(labels)
    labels = cellfun(@num2str, num2cell(datarange(:)), 'UniformOutput', false);
end

if nargin < 3 || isempty(mycolormap)
    mycolormap = hot(256);
end

if nargin < 4 || isempty(orientation)
    orientation = 'vertical';
end
    

mycdata(:,1) = linspace(min(datarange), max(datarange), 256);

mypatch = repmat(mycdata, 1, 25);
 
if contains(lower(orientation), 'horizontal')
    mypatch = transpose(mypatch);
end
 
h = figure(555);
h.Units = 'normalized';
imagesc([], mycdata, mypatch);
colormap(mycolormap);
ax = gca;
if contains(lower(orientation), 'vertical')
    h.Position(3) = 0.1;
    ax.YDir = 'normal';
    ax.Position(3) = 0.1;
    ax.Position(1) = 0.5 - ax.Position(3)/2;
    ax.YAxisLocation = 'right';
    ax.XTickLabel = [];
    ax.XTick= [];
end

% axis tight

pause(1);