function err = uncertainty_in_linefit(x, y, fit)
% 3DFM function  
% Math 
% last modified 08/24/06
%  
% Computes the uncertainty of the slope in a linear fit.  Reference used
% for this computation is John Taylor's _An Introduction to Error
% Analysis_, Section 8.4, page 159. 1982.
%  
%  [es,ei] = uncertainty_in_linefit(x, y, fit);  
%   
%  where "err" contains uncertainty measurements in [slope, intercept]
%        "x" is a vector containing x-coordinates. 
%        "y" is a vector containing y-coordinates.
%		 "fit" is the fitting vector outputted by polyfit, or 
%              in the form [slope intercept].        
%  
%  08/24/06 - created. (jcribb)
%
    N = length(x);

    if N <= 2
        logentry('You need more than two points to have measureable error. Reporting NaN for convenience.');
        sB2 = NaN;
        sA2 = NaN;
    else 
        B = fit(1);
        A = fit(2);

        delta = N * sum(x.^2) - sum(x)^2;

        sy2 = 1/(N-2) * sum( (y - A - B*x) .^ 2);

        sA2 = sy2 * sum(x.^2 ./ delta);
        sB2 = N * sy2 / delta;
    end
    
    es = sqrt(abs(sB2));
    ei = sqrt(abs(sA2));
    
    err = [es, ei];
    
%%%%
%% extraneous functions
%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'uncertainty_in_linefit: '];

     fprintf('%s%s\n', headertext, txt);

    return;
    
    