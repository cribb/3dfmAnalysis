function varargout = TrackerGUI(varargin)
% TRACKERGUI Application M-file for TrackerGUI.fig
%    FIG = TRACKERGUI launch TrackerGUI GUI.
%    TRACKERGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 15-Nov-2003 12:26:08

	if nargin == 0  % LAUNCH GUI
	
		fig = openfig(mfilename,'reuse');
		
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
%| callback type separated by '_', e.g. 'slider_Frame_Number_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider_Frame_Number. This
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
function varargout = edit_filename_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pushbutton_browse_Tracking_files_Callback(h, eventdata, handles, varargin)

    [pname, fname] = uigetfile('*.*');
	
	file_name = strcat(fname, pname);
	
	set(handles.edit_filename,'String', file_name);
    
    %Makes the file and path name global so they are available for later
    handles.pname = pname;
    guidata(h,handles);
   
    handles.fname = fname;
    guidata(h,handles);
    

    
    

% --------------------------------------------------------------------
function varargout = Load_AVI_Callback(h, eventdata, handles, varargin)

%Finds the main file name by removing all numbers and the file type

    shortname = handles.pname;

    shortname = strrep (shortname,'0','');
    shortname = strrep (shortname,'1','');
    shortname = strrep (shortname,'2','');
    shortname = strrep (shortname,'3','');
    shortname = strrep (shortname,'4','');
    shortname = strrep (shortname,'5','');
    shortname = strrep (shortname,'6','');
    shortname = strrep (shortname,'7','');
    shortname = strrep (shortname,'8','');
    shortname = strrep (shortname,'9','');
        
    %In addition to removing the file tag, this records which type of file it is
    if(findstr('.jpg',shortname) ~= [])
        shortname = strrep (shortname,'.jpg','');
        imagetype = '.jpg';
    end
    if (findstr('.tif',shortname) ~= [])
        shortname = strrep (shortname,'.tif','');
        imagetype = '.tif';
    end
    if (findstr('.bmp',shortname) ~= [])
        shortname = strrep (shortname,'.bmp','');
        imagetype = '.bmp';
    end
        
    
    %Sets the file type as global
        handles.imagetype = imagetype;
        guidata(h,handles);
        

    %Gets the numerical part of the file name by removing the tag and the non-numerical
    % name from the entire file name, then makes it global
        numberpart = strrep(handles.pname,shortname,'');
        numberpart = strrep (numberpart,handles.imagetype,'');
       
        handles.numberpart = numberpart;
        guidata(h,handles);
        
        handles.originalnumberpart = numberpart;
        guidata(h,handles);
        
        
        
     %Sets the text part as a global variable   
        handles.textpart = shortname;
        guidata(h,handles);
        
        
    %Figures out the length of the original number part and makes it global
        
        numberlength = size(handles.originalnumberpart);
        numberlength = numberlength(2);
        
        handles.numberlength = numberlength;
        guidata(h,handles);
       
        
     
    %Counts the number of files to be viewed  

    num_files = 0;


    while(1==1)   
        zerostring = '';
        
        %Generates a file based on the path name, the text name, the number, and the image tag
         filename = strcat(handles.fname,handles.textpart,handles.numberpart,handles.imagetype);
         
            %If the files exist, the counter is augmented by one
            if(exist(filename,'file'))
                num_files = num_files + 1;
                
                %Increases the number part, then adds padding zeros
                numberpart = num2str(str2num(handles.numberpart));
                
                %Finds out how many digits are in the shortened length
                curnumberlength = size(numberpart);
                curnumberlength = curnumberlength(2);
                
                %The number of zeros that will need to be added
                topcount = numberlength - curnumberlength;
                
                             %Increases the number part, then adds padding zeros
                             numberparta = str2num(numberpart) + 1;
                    
                             %Finds out how many digits are in the shortened length
                             curnumberlengtha = size(num2str(numberparta));
                             curnumberlengtha = curnumberlengtha(2);

                             %Make sure we're not about to add a digit
                             if(curnumberlength ~= curnumberlengtha)
                               topcount = numberlength - curnumberlength - 1;
                             end
                
                %Creates a string with the correct number of zeros to add
                for (i = 1:topcount)
                    zerostring = strcat(zerostring, '0');
                    i = i + 1;
                end
                    
                handles.numberpart = strcat(zerostring,num2str(str2num(handles.numberpart)+1)); 
                guidata(h,handles);
                
            else
                break
            end
        end
            
        %Saves the number of files as global
        handles.numfiles = num_files;
        guidata(h,handles);
        


   	
	% Initialize values 
	set(handles.slider_Frame_Number,'Value',1);
    set(handles.slider_Dark_Threshold,'Value',1);
    set(handles.slider_Frame_Number,'Max', num_files);
    set(handles.slider_Frame_Number,'Min', 1);
	set(handles.slider_Dark_Threshold,'Min', 1);
    set(handles.slider_Dark_Threshold,'Max', 255);
	
	
	% Load the movie into memory
	file = get(handles.edit_filename,'String');
	curimage = imread(file);
	
	
% 	% Lose the Green and Blue to make the movie smaller
% 	for k = 1:length(mov)   
%         mov(k).cdata = mov(k).cdata(:,:,1);
% 	end	
% 
%colormap(gray(256));
	
	% Make the current image global
	handles.curimage = curimage;
	guidata(h,handles);
    	  
	% Makes a figure for the image
	figure;imagesc(handles.curimage);
	
	axis off;
	
     


% --------------------------------------------------------------------
function varargout = slider_Dark_Threshold_Callback(h, eventdata, handles, varargin)

	% Sets the threshold and frame number to the values on the sliders
	cur_index = floor(get(handles.slider_Frame_Number,'Value'));
    light_thresh = floor(get(handles.slider_Light_Threshold,'Value'));
    dark_thresh = floor(get(handles.slider_Dark_Threshold,'Value'));

  	% Connects the slider to the corresponding text field
	set(handles.edit_Dark_Threshold,'String',num2str(dark_thresh));
	set(handles.slider_Dark_Threshold,'Min',1);
	set(handles.slider_Dark_Threshold,'Max',256);

    
    if (light_thresh < dark_thresh)
		set(handles.edit_Dark_Threshold,'String',num2str(light_thresh-1));
        set(handles.slider_Dark_Threshold,'Value',light_thresh-1);
    else
        set(handles.edit_Dark_Threshold, 'String', num2str(dark_thresh));
    end

	compute_threshold(h, eventdata, handles, varargin);
    
    

% --------------------------------------------------------------------
function varargout = edit_Dark_Threshold_Callback(h, eventdata, handles, varargin)

	% Connects a text field with the corresponding slider
	set(handles.slider_Dark_Threshold,'Value',str2num(get(handles.edit_filename,'String')));
	   

% --------------------------------------------------------------------
function varargout = slider_Light_Threshold_Callback(h, eventdata, handles, varargin)
	% Connects the slider to the corresponding text field
    set(handles.slider_Light_Threshold,'Min',1);
	set(handles.slider_Light_Threshold,'Max',256);

    % Sets the threshold and frame number to the values on the sliders
    cur_index = floor(get(handles.slider_Frame_Number,'Value'));
    light_thresh = floor(get(handles.slider_Light_Threshold,'Value'));
    dark_thresh = floor(get(handles.slider_Dark_Threshold,'Value'));

    if (light_thresh < dark_thresh)
		set(handles.edit_Light_Threshold,'String',num2str(dark_thresh+1));
        set(handles.slider_Light_Threshold,'Value',dark_thresh+1);
    else
        set(handles.edit_Light_Threshold, 'String', num2str(light_thresh));
    end
    
	compute_threshold(h, eventdata, handles, varargin);



% --------------------------------------------------------------------
function varargout = edit_Light_Threshold_Callback(h, eventdata, handles, varargin)

	% Connects a text field with the corresponding slider
	set(handles.slider_Light_Threshold,'Value',str2num(get(handles.edit_filename,'String')));
	


% --------------------------------------------------------------------
function varargout = slider_Frame_Number_Callback(h, eventdata, handles, varargin)

	% Sets the threshold and frame number to the values on the sliders
	thresh = floor(get(handles.slider_Dark_Threshold,'Value'));
	cur_index = floor(get(handles.slider_Frame_Number,'Value'));
    
 
    
	a = [1/(handles.numfiles - 1);.01];
	set(handles.slider_Frame_Number,'SliderStep',a);
    

  
        zerostring = '';
                        
       %Sets a variable
       numberpart = str2num(handles.originalnumberpart) + floor(get(handles.slider_Frame_Number,'Value')) - 1;
                
       %Finds out how many digits are in the shortened length
       curnumberlength = size(num2str(numberpart));
       curnumberlength = curnumberlength(2);
       

                
       %The number of zeros that will need to be added
       topcount = handles.numberlength - curnumberlength;
                

                
         %Creates a string with the correct number of zeros to add
         for (i = 1:topcount)
            zerostring = strcat(zerostring, '0');
            i = i + 1;
         end
                    
                numberstring = strcat(zerostring,num2str(numberpart)); 
                
                
                
         % Generates a file based on the path name, the text name, the number, and the image tag
         filename = strcat(handles.fname,handles.textpart,numberstring,handles.imagetype);
         
 
    %Close the figure that is currently open
    %close(figure(1));
   

    %Loads in the file and puts it to the screen
    curimage = imread(filename);
    figure(1); 
    image(curimage);
    
    %Makes the current image global
    handles.curimage = curimage;
	guidata(h,handles);
    
 
    % Connects the slider to the corresponding text field
	set(handles.edit_Frame_Number,'String',num2str(cur_index));
    
    	
 	handles.dataout(:,:,cur_index) = compute_threshold(h, eventdata, handles, varargin);
    guidata(h,handles);
    
    
% --------------------------------------------------------------------
function varargout = edit_Frame_Number_Callback(h, eventdata, handles, varargin)
	
	% Connects a text field with the corresponding slider
	set(handles.slider_Frame_Number,'Value',str2num(get(handles.edit_Frame_Number,'String')));
	
	% Allows for a changed typed number to change the image (MAYBE NOT NEEDED)
	cur_index = str2num(get(handles.edit_Frame_Number,'String'));
	
       
    
    
         %Here's where I load in different images
    
    number = (str2num(handles.originalnumberpart) + cur_index - 1)
    number = num2str(number);
    
    %close(figure(1));
        
    filename = strcat(handles.fname,handles.textpart,number,handles.imagetype)
    
    curimage = imread(filename);
    
    figure(1); 
    image(curimage);
    
    	handles.curimage = curimage;
	guidata(h,handles);
    
    





% -------------------------------------------------------------------
function varargout = compute_threshold(h, eventdata, handles, varargin)

	% Sets the threshold and frame number to the values on the sliders
	dark_thresh = floor(get(handles.slider_Dark_Threshold,'Value'));
	light_thresh = floor(get(handles.slider_Light_Threshold,'Value'));
	cur_index = floor(get(handles.slider_Frame_Number,'Value'));

	% Computes the threshold and puts up the graph
	m = im2bw(handles.curimage, dark_thresh/256);
    n = im2bw(handles.curimage, 1-light_thresh/256);
        
	w = handles.curimage(:,:,1);

    if get(handles.checkbox_Invert,'Value')
        p = ~xor(m,n);
    else
        p = xor(m,n);
    end
    p = immultiply(p,255);
    
	k(:,:,1) = w;
	k(:,:,2) = imadd(p,w);
	k(:,:,3) = w;

  	figure(1);
    imagesc(k);
	axis off;
    
%     figure(3);
%     imagesc(p);
%     colormap(gray);
%     
    
    if nargout == 1
        varargout{1} = p;
    end



% --------------------------------------------------------------------
function varargout = checkbox_Invert_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = btnSaveMat_Callback(h, eventdata, handles, varargin)

    dataout = handles.dataout;
    save('data.mat', 'dataout');


% --------------------------------------------------------------------
function varargout = btnSaveTxt_Callback(h, eventdata, handles, varargin)

    dataout = handles.dataout;
    [rows, cols, pages] = size(dataout);

    count = 1;
    
    for m = 1:rows
        for n = 1:cols
            for p = 1:pages
                data(count, :) = [m n p dataout(m,n,p)];
                count = count + 1;
            end
        end
    end
        
    save('data.txt', 'data', '-ASCII');