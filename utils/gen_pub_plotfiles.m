function gen_pub_plotfiles(outf, fig_or_figfile, type)
% GEN_PUB_PLOTFILES Generates and saves figure into several image formats.
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%  
% Uses pretty_plot to generate several files for a given figure.  Pretty 
% much a hack to save myself from repeatedly saving .eps, .png, .jpg, etc... 
% files for the figure.
%  
%  [] = gen_pub_plotfiles(outf, fig_or_figfile, type);  
%   
%  where "outf" is the output filename 
%        "fig_or_figfile" is the chosen figure handle (defaults to gcf)
%		     "type" is normal or inset, defaults to 'normal'.  'inset' has axis
%          legends and labels 25% larger to compensate for smaller overall 
%          figure size.
%  

if nargin < 3 || isempty(type)
    type = 'normal';
end

if nargin < 2 || isempty(fig_or_figfile)
    type = 'normal';
    fig_or_figfile = gcf;
end

if nargin < 1 || isempty(outf)
    error('need a root filename for which to save the data.');
end

switch type
    case 'normal'
        mag = 1;
    case 'inset'
        mag = 1.25;
    otherwise
        mag = 1;
end

try
    h = figure(fig_or_figfile);
catch
    disp('No figure handle to grab.');
    return;
end

%pretty_plot(h, 'eps', mag);

suffix = get(h, 'Name');

if ~isempty(suffix)
    outf = [outf '-' suffix];
end


set(h, 'PaperPositionMode', 'auto');
saveas(h, [outf '.fig'], 'fig');
print(h, '-r0', [outf '.eps'], '-depsc'); 
print(h, '-r0', [outf '.png'], '-dpng'); 
% print(h, '-r0', [outf '.jpg'], '-djpg'); 
plot2svg_2d([outf '.svg'], h);
close(h);

return;

