function varargout = freq_tuning_gui(varargin)
% BASIC_CHARACTERIZATION MATLAB code for basic_characterization.fig
%      BASIC_CHARACTERIZATION, by itself, creates a new BASIC_CHARACTERIZATION or raises the existing
%      singleton*.
%
%      H = BASIC_CHARACTERIZATION returns the handle to a new BASIC_CHARACTERIZATION or the handle to
%      the existing singleton*.
%
%      BASIC_CHARACTERIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BASIC_CHARACTERIZATION.M with the given input arguments.
%
%      BASIC_CHARACTERIZATION('Property','Value',...) creates a new BASIC_CHARACTERIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before basic_characterization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to basic_characterization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help basic_characterization

% Last Modified by GUIDE v2.5 25-Jul-2018 11:11:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @freq_tuning_OpeningFcn, ...
                   'gui_OutputFcn',  @freq_tuning_OutputFcn, ...
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


%OPENING FUNCTION
function freq_tuning_OpeningFcn(hObject, eventdata, handles, varargin)
global G_DA G_COMPILED TONE_CAL NOISE_CAL


handles.output = hObject;


%Store device info
RUNTIME.TDT = TDT_GetDeviceInfo(G_DA);
RUNTIME.UseOpenEx = 1;
handles = findModuleIndex_SanesLab('RZ6',handles);

%Initialize physiology
[handles,G_DA] = initializePhysiology_SanesLab(handles,G_DA);



%--------------------------------------------
%INITIALIZE GUI TEXT
%--------------------------------------------

%Initialize gui display: Inter-stim interval
ISI = G_COMPILED.OPTIONS.ISI;
set(handles.ISI_slider,'Value',ISI);
set(handles.ISI_text,'String',[num2str(ISI), ' (msec)']);

%--------------------------------------------



%Update handles structure
guidata(hObject, handles);




function varargout = freq_tuning_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;





%---------------------------------------------------------------
%PHYSIOLOGY
%---------------------------------------------------------------
%REFERENCE PHYS
function ReferencePhys_Callback(~, ~, handles)   %KP 2018-07, synapse compatibility
%The method we're using here to reference channels is the following:
%First, bad channels are removed.
%Second a single channel is selected and held aside.
%Third, all of the remaining (good, non-selected) channels are averaged.
%Fourth, this average is subtracted from the selected channel.
%This process is repeated for each good channel.
%
%The way this method is implemented in the RPVds circuit is as follows:  
%
%From Brad Buran:
%
% This is implemented using matrix multiplication in the format D x C =
% R. C is a single time-slice of data in the shape [16 x 1]. In other
% words, it is the value from all 16 channels sampled at a single point
% in time. D is a 16 x 16 matrix. R is the referenced output in the
% shape [16 x 1]. Each row in the matrix defines the weights of the
% individual channels. So, if you were averaging together channels 2-16
% and subtracting the mean from the first channel, the first row would
% contain the weights:
% 
% [1 -1/15 -1/15 ... -1/15]
% 
% If you were averaging together channels 2-8 and subtracting the mean
% from the first channel:
% 
% [1 -1/7 -1/7 ... -1/7 0 0 0 ... 0]
% 
% If you were averaging together channels 3-8 (because channel 2 was
% bad) and subtracting the mean from the first channel:
% 
% [1 0 -1/6 ... -1/6 0 0 0 ... 0]
% 
% To average channels 1-4 and subtract the mean from the first channel:
% 
% [3/4 -1/4 -1/4 -1/4 0 ... 0]
% 
% To repeat the same process (average channels 1-4 and subtract the
% mean) for the second channel, the second row in the matrix would be:
% 
% [-1/4 3/4 -1/4 -1/4 0 ... 0]


global G_DA SYN_STATUS SYN

if ~isempty(SYN_STATUS)
    G_DA = ReferencePhys_SanesLab(handles,G_DA);
elseif isempty(SYN_STATUS)
    SYN = ReferencePhys_SanesLab(handles,SYN);
end





%---------------------------------------------------------------
%SOUND CONTROLS
%---------------------------------------------------------------

%ISI SLIDER
function ISI_slider_Callback(hObject, eventdata, handles)
global G_COMPILED

ISI = get(hObject,'Value');
set(handles.ISI_text,'String',[num2str(ISI), ' (msec)']);

G_COMPILED.OPTIONS.ISI = ISI;


guidata(hObject,handles);




%---------------------------------------------------------------
%FIGURE WINDOW CONTROLS
%---------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)

%Close the figure
delete(hObject);
% 
% 
% % --- Executes on button press in ReferencePhys.
% function ReferencePhys_Callback(hObject, eventdata, handles)
% % hObject    handle to ReferencePhys (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
