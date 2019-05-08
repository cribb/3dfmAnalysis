function [d,a] = eedistangle(XYcoords)

    if isempty(XYcoords)
        d = NaN;
        a = NaN;
    elseif size(XYcoords,1) == 1
        d = 0;
        a = NaN;
    else
        d = sqrt( (XYcoords(end,1) - XYcoords(1,1)) .^2 + ...
                  (XYcoords(end,2) - XYcoords(1,2)) .^2 );
        a = atan2( XYcoords(end,2) - XYcoords(1,2), ...
                   XYcoords(end,1) - XYcoords(1,1) );
        a(a<0) = a(a<0) + 2*pi;
    end

    return