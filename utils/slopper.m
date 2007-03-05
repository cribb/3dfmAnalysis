function [slope, err] = slopper(fnum,annotate,usedata)
% 3DFM function
% Computes slope (with uncertainty) for the data inside the box drawn.
% Logscale and multiple lines on a single plot is allowed. The only lines 
% that are visible are considered for computing the slope.

if nargin <3 | isempty(usedata), usedata = 1; end;
if nargin <2 | isempty(annotate), annotate = 1; end;
figure(fnum); 
p1 = ginput(1)
ha = gca;
if usedata    
    rbbox;
    p2 = get(gca,'CurrentPoint'); p2 = p2(1,:);
else
    p2 = ginput(1)
end

if usedata
    %obtain handles of the lines in the axis
    hl = findobj(ha,'Type','Line','Visible','On');
    hl0 = findobj(ha,'Type','Line','Tag','slopper');
    hl = setdiff(hl,hl0);

    xlims = sort([p1(1),p2(1)]);
    ylims = sort([p1(2),p2(2)]);

    %Becasue the box is always a square parallel to axes, we can compare the
    %number of points that fall within box for each line, and ignore the lines
    %that have less number of points than maximum. The lines that the user
    %intended to consider should fall inside the box, and those would only be
    %the ones considered for estimating the slope.
    lastN = 0; k = 0; x = []; y = [];
    for c = 1:length(hl)
        xdata = get(hl(c),'Xdata');
        ydata = get(hl(c),'Ydata');
        ix = find(xdata >= xlims(1) & xdata <= xlims(2));
        iy = find(ydata >= ylims(1) & ydata <= ylims(2));

        iwithin = intersect(ix,iy);
        if length(iwithin) > lastN
            k=0; x = []; y = [];
        elseif length(iwithin) < lastN
            continue;
        end;
        k = k+1; lastN = length(iwithin);
        x(:,k) = xdata(iwithin);
        y(:,k) = ydata(iwithin);
    end    
else
    x = [p1(1),p2(1)]; 
    y = [p1(2),p2(2)];
end

axlim = get(ha,'xlim'); aylim = get(ha,'Ylim');
if isequal(get(ha,'Xscale'),'log')
    x = log10(x);
    axlim = log10(axlim);
    aylim = log10(aylim);
end
if isequal(get(ha,'Yscale'),'log')
    y = log10(y);
end

if usedata
    %If there are multiple lines, collapse them by removing intercepts
    for n = 1:k
        pfit = polyfit(x(:,n),y(:,n),1);
        y(:,n) = y(:,n) - pfit(2);
    end
    x = x(:); y = y(:); %make vectors from matrices
    sfit = polyfit(x,y,1);
    slope = sfit(1);
    err = uncertainty_in_slope(x, y, sfit);
else
    slope = (y(2) - y(1))/(x(2)-x(1));
    err = [];
end
if annotate
    apos = get(ha,'position'); %apos: [bottom-left_x, "_y, width, height]
    % begin drawing line from the center, so that it works for both
    % positive and negative slopes
    xd(1) = apos(1) + apos(3)/2; yd(1) = apos(2)+apos(4)/2;
    xd(2) = xd(1)+ range(x)*apos(3)/range(axlim);
    xd = xd - min(xd) + range(xd)/2;

    figslope = slope*(range(axlim)/apos(3))/(range(aylim)/apos(4));
    yd(2) = yd(1) + figslope*(xd(2)-xd(1));
    yd = yd - min(yd) + range(yd)/2;
    annotation('Line',xd,yd,'Tag','slopper','LineWidth',2,'LineStyle','--');
%     annotation('TextBox',[xd(2),yd(2),0.15,0.05],'LineStyle','none',...
%         'string',[sprintf('%.2f',slope),' ','\pm',' ',sprintf('%.3f',err)]);
    annotation('TextBox',[xd(2),yd(2),0.15,0.05],'LineStyle','none',...
        'string',[sprintf('%.2f',slope)],'FontSize', 18,'FontWeight','Bold');
end