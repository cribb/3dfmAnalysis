function varargout = TrackerGUI(varargin)
% TRACKERGUI Application M-file for TrackerGUI.fig
%    FIG = TRACKERGUI launch TrackerGUI GUI.
%    TRACKERGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 08-Jun-2003 15:16:22

% clears matlab output window.  delete this when finished coding.
% clc;

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
function varargout = edit1_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)

[pname, fname] = uigetfile('*.avi');

file_name = strcat(fname, pname);

set(handles.edit1,'String', file_name);



% --------------------------------------------------------------------
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)

%Initialize values 
set(handles.edit2,'String', 'Now adjust the threshold "\n" with the slider bar');
set(handles.slider2,'Value',1);
set(handles.slider1,'Value',1);


%Load the movie into memory
 file = get(handles.edit1,'String');
 mov = aviread(file);
 
 
 %Loses the Green and Blue to make the movie smaller
 
  
 for k = 1:length(mov)   
     mov(k).cdata = mov(k).cdata(:,:,1);
 end
 
 
 colormap(gray(256));
 
 
  
 
 
 %Make the movie file "global"
 handles.movie = mov;
 guidata(h,handles);
  
 
 %Initializes variables based on the movie file
 num_frames = max(size(mov));
 set(handles.slider2,'Max', num_frames);
 
 %Puts the first image into the picture window 
 image(mov(1).cdata);
 
 axis off;
 

%[x,y,g] = impixel(mov(1).cdata)



% --------------------------------------------------------------------
function varargout = slider1_Callback(h, eventdata, handles, varargin)

%Sets the threshold and frame number to the values on the sliders
thresh = floor(get(handles.slider1,'Value'));
cur_index = floor(get(handles.slider2,'Value'));

%Connects the slider to the coresponding text field
set(handles.edit3,'String',num2str(thresh));
set(handles.slider1,'Min',1);
set(handles.slider1,'Max',256);

 
%Computes the threshold and puts up the graph
m = im2bw(handles.movie(cur_index).cdata, handles.movie(cur_index).colormap, thresh/256);
m = immultiply(~m,255);

w = handles.movie(cur_index).cdata;

k(:,:,1) = w;
k(:,:,2) = imadd(m,w);
k(:,:,3) = w;

imagesc(k);
axis off;

% debugging figure (maybe useful later on, delete when ready)
% figure(5); 
% subplot(2,2,1); imagesc(w);  title('orig. image (w)');
% subplot(2,2,2); imagesc(m);  title('threshold (m)');
% subplot(2,2,3); imagesc(imadd(m,w));  title('m + w');
% subplot(2,2,4); imagesc(k);  title('color overlay');


% --------------------------------------------------------------------
function varargout = slider2_Callback(h, eventdata, handles, varargin)

%Sets the threshold and frame number to the values on the sliders
thresh = floor(get(handles.slider1,'Value'));
cur_index = floor(get(handles.slider2,'Value'));

a = [2/(get(handles.slider2,'Max'));.01];
set(handles.slider2,'SliderStep',a);

%Connects the slider to the coresponding text field
set(handles.edit4,'String',num2str(cur_index));

%Computes the threshold and puts up the graph
m = im2bw(handles.movie(cur_index).cdata, handles.movie(cur_index).colormap, thresh/256);
m = immultiply(~m,255);

w = handles.movie(cur_index).cdata;

k(:,:,1) = w;
k(:,:,2) = imadd(m,w);
k(:,:,3) = w;

imagesc(k);
axis off;

% debugging figure (maybe useful later on, delete when ready)
% figure(5); 
% subplot(2,2,1); imagesc(w);  title('orig. image (w)');
% subplot(2,2,2); imagesc(m);  title('threshold (m)');
% subplot(2,2,3); imagesc(imadd(m,w));  title('m + w');
% subplot(2,2,4); imagesc(k);  title('color overlay');


% --------------------------------------------------------------------
function varargout = edit2_Callback(h, eventdata, handles, varargin)






% --------------------------------------------------------------------
function varargout = edit3_Callback(h, eventdata, handles, varargin)

%Connects a text field with the coresponding slider
set(handles.slider1,'Value',str2num(get(handles.edit1,'String')));

% %Allows for a changed typed number to change the image (MAYBE NOT NEEDED)
% cur_thresh = str2num(get(handles.edit3,'String'));
% image(handles.movie(cur_index).cdata);




% --------------------------------------------------------------------
function varargout = edit4_Callback(h, eventdata, handles, varargin)

%Connects a text field with the coresponding slider
set(handles.slider2,'Value',str2num(get(handles.edit4,'String')));

%Allows for a changed typed number to change the image (MAYBE NOT NEEDED)
cur_index = str2num(get(handles.edit4,'String'));
image(handles.movie(cur_index).cdata);




% --------------------------------------------------------------------
function varargout = axes2_CreateFcn(h, eventdata, handles, varargin)

image(handles.movie(1).cdata);




% --------------------------------------------------------------------
function varargout = Exit_Callback(h, eventdata, handles, varargin)

delete(handles.figure1)


% --------------------------------------------------------------------
function varargout = File_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = Calibrate_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = MakeCalib_Callback(h, eventdata, handles, varargin)

delete(handles.figure1)

CalibrateGUIa



% --------------------------------------------------------------------
function varargout = LoadCalib_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = calibSelectEdit_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = calibAcceptButton_Callback(h, eventdata, handles, varargin)

 cal_file = get(handles.calibSelectEdit,'String');
 
 M = CSVREAD(cal_file);
 
 calib_factor = M(1);
 
 handles.calibration = calib_factor;
 guidata(h,handles);
 
 
 good_string = strcat('Current calibration:  ', num2str(handles.calibration));
 
  set(handles.calibSelectEdit,'String', good_string);
 
 
 
 
 
 
 
 




% --------------------------------------------------------------------
function varargout = calBrowseButton_Callback(h, eventdata, handles, varargin)

[pname, fname] = uigetfile('*.txt');

file_name = strcat(fname, pname);

set(handles.calibSelectEdit,'String', file_name);





% --------------------------------------------------------------------
function varargout = TrackMode_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = AutoTracking_Callback(h, eventdata, handles, varargin)

TrackerGUI


% --------------------------------------------------------------------
function varargout = ManualTrack_Callback(h, eventdata, handles, varargin)

delete(handles.figure1)

ManualTrackerGUI

