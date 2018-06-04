function varargout = plate_96wells(varargin)
% PLATE_96WELLS MATLAB code for plate_96wells.fig
%      PLATE_96WELLS, by itself, creates a new PLATE_96WELLS or raises the existing
%      singleton*.
%
%      H = PLATE_96WELLS returns the handle to a new PLATE_96WELLS or the handle to
%      the existing singleton*.
%
%      PLATE_96WELLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLATE_96WELLS.M with the given input arguments.
%
%      PLATE_96WELLS('Property','Value',...) creates a new PLATE_96WELLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plate_96wells_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plate_96wells_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plate_96wells

% Last Modified by GUIDE v2.5 30-May-2018 09:22:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plate_96wells_OpeningFcn, ...
                   'gui_OutputFcn',  @plate_96wells_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before plate_96wells is made visible.
function plate_96wells_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plate_96wells (see VARARGIN)

% Choose default command line output for plate_96wells
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plate_96wells wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plate_96wells_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
