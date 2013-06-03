function varargout = ActinMeasurer(varargin)
% ACTINMEASURER Application M-file for ActinMeasurer.fig
%    FIG = ACTINMEASURER launch ActinMeasurer GUI.
%    ACTINMEASURER('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 19-Sep-2003 14:45:12

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
       
 %Creates a browse flag
 handles.calibBrowseFlag = 0;
 guidata(fig,handles);
   
    
 
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
function varargout = FileName_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = FileNameBrowse_Callback(h, eventdata, handles, varargin)

[pname, fname] = uigetfile('*.jpg');
file_name = strcat(fname, pname);
set(handles.FileName,'String', file_name);

save_file = pname;



save_file = strrep(save_file,'.jpg','_log');
save_file = strrep(save_file,'.jpeg','_log');
save_file = strrep(save_file,'.tif','_log');
save_file = strrep(save_file,'.bmp','_log');
 
 
 
save_file = strcat(save_file,'.txt');

set(handles.SaveFileName,'String',save_file);




% --------------------------------------------------------------------
function varargout = FileNameOk_Callback(h, eventdata, handles, varargin)

	% Load the image into memory
	set(handles.Instructions,'String', 'Refer to the clicking instructions below');
	file = get(handles.FileName,'String');
	pic = imread(file);
	
	% Make the movie file "global"
	handles.image = pic;
	guidata(h,handles);
    [rows cols pages] = size(handles.image);

	% Puts the first image into the picture window 
    fig = figure(1);
    set(fig,'DoubleBuffer','on'       ...
           ,'RendererMode','manual'   ...
           ,'Renderer','zbuffer'      ...
           ,'Units','Pixels'          ...
           ,'menubar','none'          ...
           ,'Position',[200 200 cols rows]);
    
    image(handles.image);
    ax = axes;
    set(ax,'Units','Pixels');
    set(ax,'Position',[1 1 cols rows]);
    pos = get(ax,'Position');
	axis off;
    
	get(handles.DoneSampling,'Value');
	
	for i = 1:1000
	
        % Puts the first image into the picture window 
        figure(fig);
	    image(handles.image);

        figpos = get(fig, 'Position');
        set(fig,'Units','Pixels');
        set(fig,'Position',figpos);
        axis off;
        
		if(get(handles.DoneSampling,'Value')==1)
             break;
		end
		
		[x,y,g] = impixel(handles.image);
		
		del_x = x(2)-x(1);
		del_y = y(1)-y(2);
		
		dist = (handles.calibration)*sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2);
		
        angle = atan2((y(1)-y(2)),(x(2)-x(1)));
        
		angle = angle * 180 / pi;

        hold on;
        plot([x(1) ; x(2)],[y(1) ; y(2)],'r');
        drawnow;
        hold off;
        
		x1(i) = (handles.calibration)*x(1);
		y1(i) = (handles.calibration)*y(1);
		x2(i) = (handles.calibration)*x(2);
		y2(i) = (handles.calibration)*y(2);
        
		distances(i) = dist;
		angles(i) = angle;        
        
        [im,cmap] = frame2im(getframe(gcf));

        pos=get(gca,'Position');

        handles.image = im;
	end
	

    
	handles.bigmatrix = [x1;y1;x2;y2;distances;angles]';
	guidata(h,handles);
	
	
% --------------------------------------------------------------------
function varargout = Instructions_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = SaveFileName_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = SaveFileBrowse_Callback(h, eventdata, handles, varargin)

	log_directory = uigetfolder_standalone;
	file_name = get(handles.SaveFileName,'String');
	
	
	whole_name = strcat(log_directory,'\', file_name);
	
	set(handles.SaveFileName,'String', whole_name);


% --------------------------------------------------------------------
function varargout = SaveFileOk_Callback(h, eventdata, handles, varargin)


	save_file = get(handles.SaveFileName,'String');
	
	strrep(save_file,'.jpg','');
	strrep(save_file,'.jpeg','');
	strrep(save_file,'.tif','');
	strrep(save_file,'.bmp','');
	
	save_file = strcat(save_file,'.txt');
	
	
	M = [handles.bigmatrix];
	
	csvwrite(save_file,M);
	
	
	temp_str = strrep(get(handles.SaveFileName,'String'), '_log.txt','');
	
	header_one = strcat('Image Name: ', temp_str);
	header_two = strcat('Calibration Factor: ', num2str(handles.calibration));
	header_three = '';
	
	
	header = {header_one, header_two , header_three};
	
	
	
	column_names = {'x1','y1','x2','y2','length','angle'};
	
%DOES NOT WORK. xlswrite has been updated.	
	xlswrite(M, header, column_names);




% --------------------------------------------------------------------
function varargout = DoneSampling_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = CalibrationText_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = CalibrationOk_Callback(h, eventdata, handles, varargin)

	set(handles.Instructions,'String', 'Now load in an image to analyze, then hit "OK"');

    % As long as a calibration file has not been selected using browse
    if(handles.calibBrowseFlag == 0)  
        calib_factor = str2num(get(handles.CalibrationText,'String'));
        handles.calibration = calib_factor;
	    guidata(h,handles);
    end

    
    % If a calibration file has been selected, we load it
    if(handles.calibBrowseFlag == 1)
        
		cal_file = get(handles.CalibrationText,'String');
		
		M = CSVREAD(cal_file);
		
		calib_factor = M(1);
		
		handles.calibration = calib_factor;
		guidata(h,handles);
		
		set(handles.CalibrationText,'String', num2str(handles.calibration));
        
        
        % Creates a browse flag
        handles.calibBrowseFlag = 0;
        guidata(h,handles);
        
	end


% --------------------------------------------------------------------
function varargout = CalibrationBrowse_Callback(h, eventdata, handles, varargin)
	
	[pname, fname] = uigetfile('*.txt');
	
	file_name = strcat(fname, pname);
	
	set(handles.CalibrationText,'String', file_name);
	
	%Creates a browse flag
	handles.calibBrowseFlag = 1;
	guidata(h,handles);
	

% --------------------------------------------------------------------
function varargout = MakeCalibration_Callback(h, eventdata, handles, varargin)
	CalibrateGUIa;

