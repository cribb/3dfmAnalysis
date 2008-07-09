function gridcolor(varargin)
%
% function gridcolor([h_axes], [xcolor],  [ycolor],  [zcolor])
%
% Use this function to change the color of gridlines to a color different to the label and box
% color, which is currently not implemented in Matlab. 
% (-> http://www.mathworks.com/support/solutions/data/1-1PAYMC.html?solution=1-1PAYMC)
%
% Input parameters (all optional)
% -------------------------------
% hAx                   Handle of axis resp. array of handles to several axes, first arg. if specified
% xyzcolor              Color specification (e.g. 'r' or [1 0 0])
%
% Syntax
% ------
% gridcolor             Change/update the current axis (gca) with the default grid color (cstd)
% gridcolor(hAx)        Change/update axis(axes) with handle(s) hAx with the default grid color (cstd)
% gridcolor(hAx, col)   Change/update axis(axes) (hAx) with grid color col (e.g. 'r' or [1 0 0])
%
% Notes
% -----
% This function creates a second "empty" axis, which only contains the grid lines, as suggested
% in the Matlab support page. Additionally this "grid" axis is linked to the original axis to
% enable correct behavior during zooming and paning. You should not issue a "grid on" command to
% the original axis after you have used "gridcolor". This version has only been tested on Matlab
% 7, so if you're expericencing problems with Matlab 6 ... first read on and ... if this does
% not help you to solve your problems report them to me via mail.
%
% For Matlab Version 7 the linking is done using the 'linkprop'-command in line 119. The list of 
% linked properties includes everything I can think of, which may "disalign" the two axes. The 
% linking updates the second axis automatically, so you should be able to do all sorts of zooming, 
% paning, changing axis limits, axis directions, etc. If you are experiencing unwanted changes in 
% the overall display of your plot (e.g. dataaspectratio ...) you may want to take out some of the 
% properties in this line.  
%
% For Matlab 6 (or lower) gridcolor will not notice, if you change any of the following parameters 
% on the original axis: 'gridlinestyle', 'minorgridlinestyle', 'xyzscale', 'xyzdir', 'xyzlim'
% If you do change these parameters you will have to call gridcolor again, to update the gridlines !!!
%
% Example
% -------
% loglog([1 20],[1 50]);
% set(gca,'gridlinestyle','-','minorgridlinestyle',':')
% grid on
% gridcolor                         % Default color (-> gca)
% gridcolor([1 0 1])                % Change color to pink
% gridcolor('c')                    % Change color to cyan
% % Following only for Matlab 6 !!!
% set(gca,'yscale','linear')        % If you're using Matlab 6, the grid is wrong now (s. a.) !!!
% gridcolor                         % This will update your grid preserving the set colors
% 
% Author
% ------
% Sebastian Hoelz
% TU-Berlin
% [->Insert my family name<-]@geophysik.tu-berlin.de
% 
% Version 0.92 - 10.8.2006
%   Changed the stack order of the reference axis (now bottom) and the "color-axis" (now top)
%   Removed the linkaxis-command for Matlab 6.5 and lower, since it does not exist in this version
%
% Version 0.91 - 31.1.2006
%   Original Release
    
    cstd = [.8 .8 .8];       % Standard color
    persistent show_only_once
    
    % Parsing input with recursive calls to this function, 
    % if less than 4 input arguments are supplied
    % ----------------------------------------------------
    error(nargchk(0, 4, nargin))
    
    if nargin==0
        gridcolor(gca); return
        
    elseif nargin>=1 & nargin<4
        a1 = varargin{1};
        if iscolor(a1)
            % First argument seems to be a color spec. !!!
            gridcolor(gca,varargin{:}); return
            
        elseif length(a1)>1
            % First argument might be an array with handles of axes
            for i=1:length(a1); gridcolor(a1(i),varargin{2:end}); end; return
            
        else
            % Check if argument is an axis handle
            if ~ishandle(a1) | ~strcmpi(get(a1,'type'),'axes'); error('Input argument is not an axis handle'); end
            if nargin == 1
                % See if grid-axis already exists (-> axis is updated without color change!)
                ax2 = getappdata(a1,'hGridAxis');
                if ~isempty(ax2) & ishandle(ax2); cxyz=get(ax2,{'xcolor','ycolor','zcolor'}); 
                else; cxyz={cstd, cstd, cstd}; end
                gridcolor(a1,cxyz{:}); return
                
            elseif nargin == 2
                gridcolor(a1,varargin{2},varargin{2},[0 0 0]); return
                
            elseif nargin == 3
                gridcolor(a1,varargin{2},varargin{3},[0 0 0]); return
            end
        end
    end
    
    % Get / create grid axis
    ax1 = varargin{1};
    ax2 = getappdata(ax1,'hGridAxis');
    if isempty(ax2)
        ax2 = copyobj(ax1,get(ax1,'parent'));
        setappdata(ax1,'hGridAxis',ax2)
        uistack(ax2,'top')
        set(ax2,'xticklabel','','yticklabel','','zticklabel','','handlevisibility','off')
        set(ax1,'deletefcn',{@hGridAxis_delete, ax2})
    end
    
    % Set individual axes properties
    set(ax1, 'xgrid','off', 'ygrid','off', 'zgrid','off')
    set(ax2,'xcolor',varargin{2},'ycolor',varargin{3},'zcolor',varargin{4},'color','none')
    
    % Set linked properties
    if str2num(version('-release')) >= 14      
        % Matlab version 7 (or higher)
        hlink = linkprop([ax1 ax2],{'CameraPosition','CameraUpVector','CameraTarget','CameraViewAngle',  ...
            'gridlinestyle','minorgridlinestyle',...
            'xscale','yscale','zscale','xlim','ylim','zlim','xdir','ydir','zdir', ...
            'PlotBoxAspectRatio','Dataaspectratio','position','units','Projection'});

        setappdata(ax1,'axes_linkprop',hlink);
        % 
    else
        % Matlab 6.5 and lower
        set(ax2,{'CameraPosition','CameraUpVector', 'gridlinestyle','minorgridlinestyle',...
            'xscale','yscale','zscale','xlim','ylim','zlim', 'xdir','ydir','zdir'}, ...
            get(ax1, {'CameraPosition','CameraUpVector','gridlinestyle','minorgridlinestyle',...
            'xscale','yscale','zscale','xlim','ylim','zlim', 'xdir','ydir','zdir'}))
        if isempty(show_only_once)
            warning(sprintf('\n\tYour version of Matlab does not support "linkaxes". Zooming and panning will not work\n\tTo update axis reissue command GridColor(hax) after panning or zooming !!!'))
        end
    end
        
   
    
% ------------------------    
function out = iscolor(in)
    % See if input argument is a valid Matlab color specification
	out = (isstr(in) & any(strcmpi(in,{'y','m','c','r','g','b','w','k'}))) || (isnumeric(in) & length(in)==3 &  all(in>=0) & all(in<=1)); 

% ---------------------------    
function hGridAxis_delete(varargin)
    try; delete(varargin{3}); end
    
    