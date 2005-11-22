function varargout = poletipsmeasurer(varargin)
% POLETIPSMEASURER Application M-file for poletipsmeasurer.fig
%    FIG = POLETIPSMEASURER launch poletipsmeasurer GUI.
%    POLETIPSMEASURER('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 19-Nov-2003 13:05:16

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end

%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = txtCalibration_Callback(h, eventdata, handles, varargin)

    
        
% --------------------------------------------------------------------
function varargout = btnBrowse_Callback(h, eventdata, handles, varargin)

	[pname, fname] = uigetfile('*.jpg');
	file_name = strcat(fname, pname);
	set(handles.txtFilename,'String', file_name);
	
	save_file = pname;
	save_file = strrep(save_file,'.jpg','_log');
	save_file = strrep(save_file,'.jpeg','_log');
	save_file = strrep(save_file,'.tif','_log');
	save_file = strrep(save_file,'.bmp','_log');
     
	save_file = strcat(save_file,'.txt');
    

% --------------------------------------------------------------------
function varargout = btnLoadFile_Callback(h, eventdata, handles, varargin)

    coord = setupImage(h, eventdata, handles, varargin);
	
    calib_um = str2num(get(handles.txtCalibration,'String'));
    %calib_um = calib_um * 1e-6;
    
    dist = distances(coord) * calib_um;
    cent = pole_center(coord)    * calib_um;
    regularity = pole_regularity(dist);
    
    assignin('base','coords',coord);
    assignin('base','dists',dist);
    assignin('base','cents',cent);
    
%    cent*1e6
    
    
% ---------------------------------
function v = setupImage(h, eventdata, handles, varargin)

    % Load the image into memory
	file = get(handles.txtFilename,'String');
	pic = imread(file);
	
	% Make the movie file "global"
	handles.image = pic;
	guidata(h,handles);
    
    [rows cols pages] = size(pic);

	% Puts the image into the picture window 
    fig = figure(1);
    set(fig,'DoubleBuffer','on'       ...
           ,'RendererMode','manual'   ...
           ,'Renderer','zbuffer'      ...
           ,'Units','Pixels'          ...
           ,'menubar','none');
    
    image(pic);
	axis off;

	[xval,yval,gval] = impixel(pic);
    
    v = [xval yval];
    
    
        

% --------------------------------------------------------------------
function varargout = txtFilename_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------    
function varargout = FileNameOk_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = btnExport_Callback(h, eventdata, handles, varargin)

