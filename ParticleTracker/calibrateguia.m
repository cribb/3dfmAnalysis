function varargout = CalibrateGUIa(varargin)
% CALIBRATEGUIA Application M-file for CalibrateGUIa.fig
%    FIG = CALIBRATEGUIA launch CalibrateGUIa GUI.
%    CALIBRATEGUIA('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 07-Jun-2003 14:47:52

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
function varargout = fileEdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = browseButton_Callback(h, eventdata, handles, varargin)

[pname, fname] = uigetfile('*.jpg');

file_name = strcat(fname, pname);

set(handles.fileEdit,'String', file_name);


% --------------------------------------------------------------------
function varargout = okButton_Callback(h, eventdata, handles, varargin)

%Load the movie into memory
set(handles.instructions,'String', 'Click a start and end point, then press return');
 file = get(handles.fileEdit,'String');
 pic = imread(file);
 
 
 %Make the movie file "global"
 handles.cal_image = pic;
 guidata(h,handles);
  

 
 %Puts the first image into the picture window 
 image(handles.cal_image);
 
 axis off;
 

[x,y,g] = impixel(handles.cal_image);

dist = sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2);

 handles.distance = dist;
 guidata(h,handles);



% --------------------------------------------------------------------
function varargout = calibEdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = distEdit_Callback(h, eventdata, handles, varargin)





% --------------------------------------------------------------------
function varargout = calcButton_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = distOkButton_Callback(h, eventdata, handles, varargin)




final_cal = str2num(get(handles.distEdit, 'string')) / handles.distance;

set(handles.calibEdit,'string', num2str(final_cal));





% --------------------------------------------------------------------
function varargout = instructions_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit5_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pushbutton5_Callback(h, eventdata, handles, varargin)

log_directory = uigetfolder_standalone;
file_name = get(handles.edit5,'String');


whole_name = strcat(log_directory,'\', file_name);

set(handles.edit5,'String', whole_name);







% --------------------------------------------------------------------
function varargout = pushbutton6_Callback(h, eventdata, handles, varargin)

 save_file = get(handles.edit5,'String');



final_calibration = str2num(get(handles.calibEdit,'string'));

M = [final_calibration];

csvwrite(save_file,M)




% --------------------------------------------------------------------
function varargout = exitButton_Callback(h, eventdata, handles, varargin)

delete(handles.figure1)
