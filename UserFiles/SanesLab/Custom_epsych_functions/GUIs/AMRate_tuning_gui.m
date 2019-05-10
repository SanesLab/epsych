function varargout = AMRate_tuning_gui(varargin)
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

% Last Modified by GUIDE v2.5 11-Mar-2019 16:18:32

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
global G_DA G_COMPILED NOISE_CAL RUNTIME AX SYN SYN_STATUS

%Store device info
RUNTIME.TDT = TDT_GetDeviceInfo(G_DA);
RUNTIME.UseOpenEx = 1;
handles = findModuleIndex_SanesLab('RZ6',handles);

%Initialize physiology settings for multi channel recording (if OpenEx)
[handles,AX] = initializePhysiology_SanesLab(handles,AX);
if strcmp(get(handles.ReferencePhys,'enable'),'on') %kp 11/2017
    
    %If we're not running synapse, update via open developer controls
    if ~isempty(SYN_STATUS)
        AX = ReferencePhys_SanesLab(handles,AX);
        
    %If we're running Synapse, update via Synapse API    
    elseif isempty(SYN_STATUS)
        SYN = ReferencePhys_SanesLab(handles,SYN);
    end
    
    
end

%%%%%%%%
bandwidth = G_COMPILED.trials(1,strcmp(G_COMPILED.writeparams,'Behavior.BandRatio'));
if( ~isempty(bandwidth) )    
    center_freq = G_COMPILED.trials(1,strcmp(G_COMPILED.writeparams,'Behavior.Freq'));
    center_freq = center_freq{1};
    bandwidth = bandwidth{1};
    hp = center_freq - (bandwidth*center_freq/2);
    lp = center_freq + (bandwidth*center_freq/2);
    
    %Avoid hp filter values that are too low (not sure why this is a problem,
    %but if the value is too low, the filter component macro in the RPVds
    %circuit stops working.)
    if hp < 10
        hp = 10;
    end
    %Avoid lp filter values that are too high for the sampling rate of the
    %device (nyquist)
    if lp > 48000
        lp = 48000;
    end
    %Send the filter frequencies to the RPVds circuit
    G_DA.SetTargetVal([handles.module,'.FiltHP'],hp);
    G_DA.SetTargetVal([handles.module,'.FiltLP'],lp);

    G_DA.SetTargetVal('Behavior.HPFreq',hp);
    G_DA.SetTargetVal('Behavior.LPFreq',lp);
    
    G_DA.SetTargetVal([handles.module,'.~Freq_norm'],NOISE_CAL.hdr.cfg.ref.norm);

    %Calculate the voltage adjustment
    CalAmp = NOISE_CAL.data(1,4);
    %Send the values to the RPvds circuit
    G_DA.SetTargetVal([handles.module,'.~Freq_Amp'],CalAmp);
    dBSPL = G_COMPILED.trials(1,strcmp(G_COMPILED.writeparams,'Behavior.dBSPL'));
    dBSPL = dBSPL{1};
    G_DA.SetTargetVal([handles.module,'.dBSPL'],dBSPL);
    %%%%%%%%
else
    %%%%%%%%
    dBSPL = G_COMPILED.trials(1,strcmp(G_COMPILED.writeparams,'Behavior.dBSPL'));
    dBSPL = dBSPL{1};
    G_DA.SetTargetVal('Behavior.~Cal_norm',NOISE_CAL.hdr.cfg.ref.norm);
    
    %Calculate the voltage adjustment
    CalAmp = NOISE_CAL.data(1,4);
    %Send the values to the RPvds circuit
    G_DA.SetTargetVal('Behavior.~Cal_Amp',CalAmp);
    G_DA.SetTargetVal('Behavior.dBSPL',dBSPL);
    %%%%%%%%
end

% %%%%%%%%
handles.output = hObject;


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

%REFERENCE PHYSIOLOGY BUTTON
function ReferencePhys_Callback(~, ~, handles)
global AX SYN_STATUS SYN

handles = TrialDelivery_Callback_SanesLab(handles,'off');

if ~isempty(SYN_STATUS)
    AX = ReferencePhys_SanesLab(handles,AX);
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
