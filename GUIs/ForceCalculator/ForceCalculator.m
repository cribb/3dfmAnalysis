function varargout = ForceCalculator(varargin)
% FORCECALCULATOR M-file for ForceCalculator.fig
%      FORCECALCULATOR, by itself, creates a new FORCECALCULATOR or raises the existing
%      singleton*.
%
%      H = FORCECALCULATOR returns the handle to a new FORCECALCULATOR or the handle to
%      the existing singleton*.
%
%      FORCECALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FORCECALCULATOR.M with the given input arguments.
%
%      FORCECALCULATOR('Property','Value',...) creates a new FORCECALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ForceCalculator_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ForceCalculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ForceCalculator

% Last Modified by GUIDE v2.5 04-Jun-2004 11:12:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ForceCalculator_OpeningFcn, ...
                   'gui_OutputFcn',  @ForceCalculator_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


global fileName
global beadDiameter
global viscosity
global calibration
global doVariableCurrents
global numCurrents
global timePerCurrent
global startClipMatrix
global endClipMatrix
global allBeadCurrentNum
global doAllBeadSurfacePlot
global doAllBeadForcePoints
global doAllBeadForceDisp
global oneBeadBeadNumber
global oneBeadCurrentNum
global doOneBeadForceDisp
global doClipAccuracyVerification
global doSeperatePlots
global doSubplots
global doPlotAsLine
global doPlotAsPoints
global xUnitsOffset

global beginClip
global endClip



% --- Executes just before ForceCalculator is made visible.
function ForceCalculator_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ForceCalculator (see VARARGIN)

% Choose default command line output for ForceCalculator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ForceCalculator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ForceCalculator_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




function variableCurrentCheckbox_Callback(hObject, eventdata, handles)

if(get(handles.variableCurrentCheckbox,'Value')==1)
    set(handles.numCurrentsEdit,'String','');

    
    set(handles.numCurrentsText,'ForegroundColor',[0 0 0]);
    %set(handles.timePerCurrentText,'ForegroundColor',[0 0 0]);
    set(handles.allBeadCurrentNumberText,'ForegroundColor',[0 0 0]);
    
    set(handles.numCurrentsEdit,'Enable','On');
    %set(handles.timePerCurrentEdit,'Enable','On');
    set(handles.allBeadCurrentNumberEdit,'Enable','On');
   

    
    set(handles.timePerCurrentText,'Visible','On');
    set(handles.granularityText,'Visible','Off');
    
    
    
   
else
    set(handles.numCurrentsEdit,'String','Click "Using Variable Currents"');
    set(handles.allBeadCurrentNumberEdit,'String','');
    
    set(handles.numCurrentsText,'ForegroundColor',[.502 .502 .502]);
    %set(handles.timePerCurrentText,'ForegroundColor',[.7529 .7529 .7529]);
    set(handles.allBeadCurrentNumberText,'ForegroundColor',[.502 .502 .502]);
    
    set(handles.numCurrentsEdit,'Enable','Off');
    
    set(handles.allBeadCurrentNumberEdit,'Enable','Off');
    
    set(handles.timePerCurrentText,'Visible','Off');
    set(handles.granularityText,'Visible','On');
    
    
end

function allBeadSurfacePlotCheckbox_Callback(hObject, eventdata, handles)





function allBeadsForcePointsCheckbox_Callback(hObject, eventdata, handles)





function oneBeadForceDispCheckbox_Callback(hObject, eventdata, handles)




function clipAccuracyCheckbox_Callback(hObject, eventdata, handles)
if(get(handles.clipAccuracyCheckbox,'Value'))
    set(handles.subplotsRadioButton,'Enable','On');
    set(handles.seperateRadiobutton,'Enable','On');
else
    set(handles.subplotsRadioButton,'Enable','Off');
    set(handles.seperateRadiobutton,'Enable','Off');
end





function fileNameEdit_CreateFcn(hObject, eventdata, handles)


function fileNameEdit_Callback(hObject, eventdata, handles)


function beadDiameterEdit_CreateFcn(hObject, eventdata, handles)


function beadDiameterEdit_Callback(hObject, eventdata, handles)


function viscosityEdit_CreateFcn(hObject, eventdata, handles)


function viscosityEdit_Callback(hObject, eventdata, handles)


function numCurrentsEdit_CreateFcn(hObject, eventdata, handles)


function numCurrentsEdit_Callback(hObject, eventdata, handles)


function timePerCurrentEdit_CreateFcn(hObject, eventdata, handles)


function timePerCurrentEdit_Callback(hObject, eventdata, handles)


function startClipEdit_CreateFcn(hObject, eventdata, handles)


function startClipEdit_Callback(hObject, eventdata, handles)


function endClipEdit_CreateFcn(hObject, eventdata, handles)


function endClipEdit_Callback(hObject, eventdata, handles)


function allBeadCurrentNumberEdit_CreateFcn(hObject, eventdata, handles)


function allBeadCurrentNumberEdit_Callback(hObject, eventdata, handles)


function oneBeadBeadNumberEdit_CreateFcn(hObject, eventdata, handles)


function oneBeadBeadNumberEdit_Callback(hObject, eventdata, handles)


function browseButton_Callback(hObject, eventdata, handles)

global fileName

[pname, fname] = uigetfile('*.mat');

fileName = strcat(fname, pname);

set(handles.fileNameEdit,'String', fileName);



function doItButton_Callback(hObject, eventdata, handles)

%%%% The surface feature won't work until I go in and remove all rows that
%%%% contain NaN from the data.



global fileName  
global beadDiameter
global viscosity
global calibration
global doVariableCurrents
global numCurrents
global timePerCurrent
global startClipMatrix
global endClipMatrix
global allBeadCurrentNum
global xUnitsOffset
global doAllBeadSurfacePlot
global doAllBeadForcePoints
global doAllBeadForceDisp
global oneBeadBeadNumber
global oneBeadCurrentNum
global doOneBeadForceDisp
global doClipAccuracyVerification
global doSeperatePlots
global doSubplots

global beginClip
global endClip



doVariableCurrents = get(handles.variableCurrentCheckbox,'Value');
doAllBeadSurfacePlot = get(handles.allBeadSurfacePlotCheckbox,'Value');
doAllBeadForcePoints = get(handles.allBeadsForcePointsCheckbox,'Value');
doAllBeadForceDisp = get(handles.allBeadForceDispCheckbox,'Value');
doOneBeadForceDisp = get(handles.oneBeadForceDispCheckbox,'Value');
doClipAccuracyVerification = get(handles.clipAccuracyCheckbox,'Value');
doSeperatePlots = get(handles.seperateRadiobutton,'Value');
doSubplots = get(handles.subplotsRadioButton,'Value');

doPlotAsLine = get(handles.plotAsLineCheckbox,'Value');
doPlotAsPoints = get(handles.plotAsPointsCheckbox,'Value');


fileName = (get(handles.fileNameEdit,'String'));
beadDiameter = str2num(get(handles.beadDiameterEdit,'String'));
viscosity = str2num(get(handles.viscosityEdit,'String'));
calibration = str2num(get(handles.calibrationEdit,'String'));
numCurrents = str2num(get(handles.numCurrentsEdit,'String'));
timePerCurrent = str2num(get(handles.timePerCurrentEdit,'String'));
startClipMatrix = str2num(get(handles.startClipEdit,'String'));
endClipMatrix = str2num(get(handles.endClipEdit,'String'));
allBeadCurrentNum = str2num(get(handles.allBeadCurrentNumberEdit,'String'));
oneBeadBeadNumber = str2num(get(handles.oneBeadBeadNumberEdit,'String'));
xUnitsOffset = str2num(get(handles.xUnitsOffsetEdit,'String'));






 if(get(handles.absolutePositionRadiobutton,'Value'))
     d = load_video_tracking(fileName,30,[],1,'rectangle','um',calibration,'absolute');
 else
     d = load_video_tracking(fileName,30,[],1,'rectangle','um',calibration,'relative');
 end




[d.video.x d.video.y d.video.r beginClip endClip] = force_clipper(startClipMatrix,endClipMatrix, d.video.x, d.video.y, d.video.r);

beginClip = beginClip';
endClip = endClip';

set(handles.startClipEdit,'String',num2str(beginClip))
set(handles.endClipEdit,'String',num2str(endClip))


    num_columns = size(d.video.x);
    num_columns = num_columns(1,2);
    num_points = size(d.video.x);
    num_points = num_points(1,1);
    
    total_elements = [0 0 0];


    end_points_count = 1;
    
%Looks at each one of the beads
for current_col=1: num_columns
    
    %Based on the resolution that the user selects (timePerCurrent), this goes
    %through and parses the positions into segments
    
    
    for i = 1:(timePerCurrent*30):num_points

        
        
        
        if(  i <=(endClip(current_col)-beginClip(current_col) + 1)  )
            
            total_elements(current_col) = total_elements(current_col)+1;

            x_end_points(end_points_count,current_col) = d.video.x(i,current_col);
            y_end_points(end_points_count,current_col) = d.video.y(i,current_col);
            
            end_points_count = end_points_count + 1;
        end
    end
    
    end_points_count = 1;
end

%This bumps the number of elements down to the correct value
total_elements = total_elements - 1;



%This turns all 0 end points into NaNs
filler_endpoints = find((x_end_points)==0);

for i = length(x_end_points):-1:1
    x_end_points(filler_endpoints) = NaN;
    y_end_points(filler_endpoints) = NaN;
end




for current_col=1: num_columns   
    
    
    num_points = size(x_end_points(:,current_col));
    num_points = num_points(1,1);
    
    %Based on the x and y end points, an average point is calculated for x
    %and y, and a force is calculated and associated with these x and y
    %points
    for j = 2:num_points
               
        
        
        xposition = floor((x_end_points(j,current_col) + x_end_points(j-1,current_col))/2);
        yposition = floor((y_end_points(j,current_col) + y_end_points(j-1,current_col))/2);
        force = 6*pi*beadDiameter/2*viscosity*1E-6* sqrt((x_end_points(j,current_col) - x_end_points(j-1,current_col))^2 + (y_end_points(j,current_col) - y_end_points(j-1,current_col))^2) / timePerCurrent;
             
        %Changes the scale and puts the force into piconewtons
        force = force * 1E12;
        

        %Calculates the index number based on other indices
        index_number = j+((current_col-1) * max(size(x_end_points)))-1;
        
        
        

        
        
        force_list(index_number,1) = xposition;                         %X Position
        force_list(index_number,2) = yposition;                         %Y Position
        force_list(index_number,3) = force;                             %Force
        force_list(index_number,4) = current_col;                       %Bead Number
        force_list(index_number,5) = sqrt(xposition^2 + yposition^2);   %Bead Displacement (from origin)
    end   
end








%This turns all 0 forces into NaNs
zero_forces = find(force_list(:,3)==0);

for i = length(zero_forces):-1:1   
    force_list(zero_forces(i),1) = NaN;
    force_list(zero_forces(i),2) = NaN;
    force_list(zero_forces(i),3) = NaN;
    force_list(zero_forces(i),4) = NaN;
    force_list(zero_forces(i),5) = NaN;
end




%This clips out all rows that contain NaN's.

bad_rows = find(isnan(force_list(:,3)));
force_length = length(force_list);

for i = length(bad_rows):-1:1
 
    part1 = force_list(1:bad_rows(i)-1,:);
    part2 = force_list(bad_rows(i)+1:end,:);
    
    if(bad_rows(i)==force_length)
        force_list = part1;
        force_length = force_length -1;
    else
        force_list = [part1 ; part2];
        force_length = force_length -1;
    end
end




%Displays a graph with actual displacement data overlaid with circles,
%showing where the data is sampled via the algorithm described above.
if(doClipAccuracyVerification)

    if(doSubplots)
        figure(100);
         for curr=1:num_columns
             
             len = 1:(30*timePerCurrent):(endClip(curr)-beginClip(curr));
        
             subplot(num_columns,1,curr), hold on, plot(len,d.video.r(len,curr),'o'),plot(d.video.r(1:(endClip(curr)-beginClip(curr)),curr),'r'), hold off;
        
      
         end  
     end
     
     if(doSeperatePlots)
         
             for curr=1:num_columns
        
                 len = 1:(30*timePerCurrent):(endClip(curr)-beginClip(curr));

                figure(curr+100);
                 
                xlabel('Index')
                ylabel('Bead Displacement')
                title('Verification that clipping was done correctly')
                 
             hold on
             plot(len,d.video.r(len,curr),'o')
             plot(d.video.r(1:(endClip(curr)-beginClip(curr)),curr),'r')
             hold off
        
      
         end  
     end
end


% The following method goes through each bead and picks out each force point
% for the selected voltage from the GUI


if(doVariableCurrents)
    
    total_elements;
    
    selected_voltage = allBeadCurrentNum;
	clipped_row_count = 1;
		
	for selected_bead=1:num_columns


    if(selected_bead > 1)
	    offset = offset + total_elements(selected_bead-1);
    else
        offset = 1;
    end
    
	
	for index = (offset + selected_voltage-1):numCurrents:(offset + total_elements(selected_bead) - 1)

            clipped_force_list(clipped_row_count,1) = force_list(index,1);
            clipped_force_list(clipped_row_count,2) = force_list(index,2);
            clipped_force_list(clipped_row_count,3) = force_list(index,3);
            clipped_force_list(clipped_row_count,4) = force_list(index,4);
            clipped_force_list(clipped_row_count,5) = force_list(index,5);
            
            
            clipped_row_count = clipped_row_count + 1;
		end
    end
    
    
    force_list = clipped_force_list;
    
    
end



if(doAllBeadSurfacePlot)
    %SURFACE PLOT
    figure(1);
    set(gcf,'Name','Surface Plot');
    xi = 0:1:640; 
    yi = 0:1:480; 
    [XI,YI] = meshgrid(xi,yi);
    ZI = griddata(force_list(:,1),force_list(:,2),force_list(:,3),XI,YI);
    mesh(XI,YI,ZI)
end


if(doAllBeadForcePoints)
    %POINTS FOR ALL BEADS AND ALL VOLTAGES PLOT
    figure(2);
    set(gcf,'Name','Force Points');
    plot3(force_list(:,1),force_list(:,2),force_list(:,3),'.')
    xlabel('X Position (Microns)')
    ylabel('Y Position (Microns)')
    zlabel('Force (PicoNewtons)')
    title('Force vs. Position')
end




if(doAllBeadForceDisp)

    figure(8);
    set(gcf,'Name','Force List');
    xlabel('Displacement (microns)')
    ylabel('Force (pN)')
    title('Force vs. Position under Variable Currents')
    
    for beadNumber=1:num_columns
        count = 1;
        tempx = 0;
        tempy = 0;
    
        for temp = 1:length(force_list(:,4))
            if(force_list(temp,4) == beadNumber)
                tempx(count) = force_list(temp,3);
                tempy(count) = force_list(temp,5);
    
                count = count+1;
            end
        end
    
        
            tempy = tempy - xUnitsOffset;
        
        
    if(doPlotAsPoints & ~doPlotAsLine)
        hold on
        plot(tempy,tempx,'o')
        hold off
    end
    if (doPlotAsLine & ~doPlotAsPoints)
        hold on
        plot(tempy,tempx,'r')
        hold off
    end
        
    if (doPlotAsLine & doPlotAsPoints)
        hold on
        plot(tempy,tempx,'r')
        plot(tempy,tempx,'o')
        hold off
    end
        
    end
    
end





if(doOneBeadForceDisp)
    count = 1;
    tempx = 0;
    tempy = 0;
    
    for temp = 1:length(force_list(:,4))

        if(force_list(temp,4) == oneBeadBeadNumber)
            tempx(count) = force_list(temp,3);
            tempy(count) = force_list(temp,5);
    
            count = count+1;
        end
    end
    
    tempy = tempy - xUnitsOffset;


    figure(4);
    set(gcf,'Name','Force List');
    %plot(tempx,tempy)
    xlabel('Displacement (pixels)')
    ylabel('Force (pN)')
    title('Force vs. Position under Variable Currents')
    
    
    if(doPlotAsPoints & ~doPlotAsLine)
        plot(tempy,tempx,'o')
    end
    if (doPlotAsLine & ~doPlotAsPoints)
        plot(tempy,tempx,'r')
    end
        
    if (doPlotAsLine & doPlotAsPoints)
        hold on
        plot(tempy,tempx,'r')
        plot(tempy,tempx,'o')
        hold off
    end
end













function calibrationEdit_CreateFcn(hObject, eventdata, handles)



function calibrationEdit_Callback(hObject, eventdata, handles)




function subplotsRadioButton_Callback(hObject, eventdata, handles)
    set(handles.seperateRadiobutton,'Value',0);


function seperateRadiobutton_Callback(hObject, eventdata, handles)
    set(handles.subplotsRadioButton,'Value',0);


function allBeadForceDispCheckbox_Callback(hObject, eventdata, handles)




function absolutePositionRadiobutton_Callback(hObject, eventdata, handles)
    set(handles.relativePositionRadiobutton,'Value',0);

function relativePositionRadiobutton_Callback(hObject, eventdata, handles)
    set(handles.absolutePositionRadiobutton,'Value',0);


function xUnitsOffsetEdit_CreateFcn(hObject, eventdata, handles)



function xUnitsOffsetEdit_Callback(hObject, eventdata, handles)



function plotAsPointsCheckbox_Callback(hObject, eventdata, handles)



function plotAsLineCheckbox_Callback(hObject, eventdata, handles)
