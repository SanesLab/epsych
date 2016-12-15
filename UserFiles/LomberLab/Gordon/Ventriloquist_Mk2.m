function varargout = Ventriloquist_Mk2(varargin)
% Ventriloquist_Mk2 MATLAB code for Ventriloquist_Mk2.fig
%      Ventriloquist_Mk2, by itself, creates a new Ventriloquist_Mk2 or raises the existing
%      singleton*.
%
%      H = Ventriloquist_Mk2 returns the handle to a new Ventriloquist_Mk2 or the handle to
%      the existing singleton*.
%
%      Ventriloquist_Mk2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Ventriloquist_Mk2.M with the given input arguments.
%
%      Ventriloquist_Mk2('Property','Value',...) creates a new Ventriloquist_Mk2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Ventriloquist_Mk2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Ventriloquist_Mk2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Ventriloquist_Mk2

% Last Modified by GUIDE v2.5 30-Mar-2016 14:02:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Ventriloquist_Mk2_OpeningFcn, ...
                   'gui_OutputFcn',  @Ventriloquist_Mk2_OutputFcn, ...
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


% --- Executes just before Ventriloquist_Mk2 is made visible.
function Ventriloquist_Mk2_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for Ventriloquist_Mk2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

T = CreateTimer(handles.figure1);

global motorBox LEDuino Trials Azi Ele

Azi = 0;
Ele = 0;

if ~isempty(motorBox), delete(motorBox); end
if ~isempty(LEDuino),  delete(LEDuino);  end
    
motorBox = serial('COM5');
set(motorBox,'BaudRate',9600);
fopen(motorBox);

Trials = randi(4,1000,1);
LEDuino = serial('COM4');
set(LEDuino,'BaudRate',115200);
fopen(LEDuino);
pause(2);

start(T);


% --- Outputs from this function are returned to the command line.
function varargout = Ventriloquist_Mk2_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


%Button to start a zero the FASTRAK
function boresightButton_Callback(hObject, eventdata, handles)
global FASTRAK Azi Ele LEDuino
x = pollFastrak(FASTRAK,0,0);
Azi = x(5);
Ele = x(6);
set(handles.aziText,'String',Azi);
set(handles.eleText,'String',Ele);


%Button to set bore values for FASTRAK
function manualBore_Callback(hObject, eventdata, handles)
global Azi Ele
Azi = str2num(handles.aziText.String);
Ele = str2num(handles.eleText.String);


function fixateTime_Callback(hObject, eventdata, handles)
global fixateTime
fixateTime = str2num(handles.fixateText.String);



%Button to start a trial from the GUI
function trialbutton_Callback(hObject, eventdata, handles)
global LEDuino
fprintf(LEDuino,'%d',0);
%TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*StartTrial',1);
%TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*StartTrial',0);
% AX.SetTagVal('*StartTrial',1);
% AX.SetTagVal('*StartTrial',0);
disp('Resetting LEDs');

%Button to give a food reward without a "hit"
function manualFeed_Callback(hObject, eventdata, handles)
global RUNTIME AX
TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*MANUALFEED',1);
TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*MANUALFEED',0);


%Changes the amount of time the food actuator runs. Does not change the
%speed.
function newFoodDuration_Callback(hObject, eventdata, handles)
global RUNTIME AX

TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.FOODAMOUNT',str2num(handles.foodDuration.String));


%Empties the hit/miss table
function clearTableButton_Callback(hObject, eventdata, handles)
global RUNTIME AX FASTRAK
set(handles.pastTrials,'data',[],'ColumnName',{'Target','Fixed','Hit?'});


%When the inhibit radio button is depressed no trials may occur
function inhibitButton_Callback(hObject, eventdata, handles)
global RUNTIME AX

if TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INHIBIT')
    TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INHIBIT',0);
else
    TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INHIBIT',1);
end


%When this is selected the user can choose which region to focus on
function manualOverride_KeyPress(hObject, eventdata, handles)
if strcmp(handles.regionSlider.Visible,'on')
    handles.regionSlider.Visible = 'off';
    handles.manualTarget.Visible = 'off';
else
    handles.regionSlider.Visible = 'on';
    handles.manualTarget.Visible = 'on';
end

%Selects the region in conjunction with the manualOverride radio button
function regionSlider_Callback(hObject, eventdata, handles)
val=round(hObject.Value);
hObject.Value=val;
handles.manualTarget.String = int2str(val);




% Timer Functions --------------------------------------

function T = CreateTimer(f)
% Create new timer for RPvds control of experiment
T = timerfind('Name','BoxTimer');
if ~isempty(T)
    stop(T);
    delete(T);
end

T = timer('BusyMode','drop', ...
    'ExecutionMode','fixedSpacing', ...
    'Name','BoxTimer', ...
    'Period',0.05, ...
    'StartFcn',{@BoxTimerSetup,f}, ...
    'TimerFcn',{@BoxTimerRunTime,f}, ...
    'ErrorFcn',{@BoxTimerError}, ...
    'StopFcn', {@BoxTimerStop}, ...
    'TasksToExecute',inf, ...
    'StartDelay',1);







function BoxTimerSetup(~,~,f)
global FASTRAK

try
    if isempty(FASTRAK) || ~isa(FASTRAK,'serial') || isequal(FASTRAK.Status,'closed')
        FASTRAK = startFastrak;
        set(FASTRAK,'BaudRate',115200);
    end
catch me
    if isequal(me.identifier,'MATLAB:serial:get:invalidOBJ')
        FASTRAK = startFastrak;
    else
        rethrow(me);
    end
end



function BoxTimerRunTime(~,~,f)
% global variables
% RUNTIME contains info about currently running experiment including trial data collected so far
% AX is the ActiveX control being used

global RUNTIME AX FASTRAK motorBox LEDuino Azi Ele fixateTime
%currentTrial holds variables for the last full trial to be displayed on
%the GUI
persistent lastupdate currentTrial cumulFASTRAK Headings Tolerance initBuffSize LED_Sig  % persistent variables hold their values across calls to this function


try
    % number of trials is length of
    ntrials = RUNTIME.TRIALS.DATA(end).TrialID;
    
    if isempty(ntrials)
        ntrials = 0;
        lastupdate = 0;
        Headings = [-75 -40 -25 -20 -15 -10 -5 0 5 10 15 20 25 40 75];
        Tolerance = [5 5 5 5 5 5 3 3 3 5 5 5 5 5 5];
        initBuffSize = 20;
        fixateTime = 10;
        LED_Sig = SelectTrial(RUNTIME.TRIALS,'*LED_Signature');
    end
    
    
    
    h = guidata(f);

    Target = SelectTrial(RUNTIME.TRIALS,'SpeakerID') + 1;
    set(h.foodmL,'String',num2str(sprintf('%0.1f',checkSyringe(motorBox))));
    
    
    %Display the target region
    set(h.targetText,'String',int2str(Headings(Target)));
    
    %Initializes currentTrial for the first run through of the code
    if isempty(currentTrial)
        currentTrial = [Target nan nan nan];
    end
    
    %Reset X to 0 before looking to see if the response window is open. X
    %defines whether or not the trial resulted in a hit
    X = 0;
    try
        %Check for inhibition
        if TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INHIBIT')
            fprintf(LEDuino,'%d',0);
        else
            fprintf(LEDuino,'%d',64);
        end
        
        %Get the data from FASTRAK
        x = pollFastrak(FASTRAK,Azi,Ele);
        cumulFASTRAK = [cumulFASTRAK;x];
        
        %Look at FASTRAK output and determine in which region the receiver is
        %pointed

        Y = checkFixate3([x(5) x(6)],fixateTime,2);
        if Y
            checkFixate3([90 90],fixateTime,Tolerance(Target));     
            TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*StartTrial',1);
            TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*StartTrial',0);
            TDTpartag(AX,RUNTIME.TRIALS,'Speakers.Switch_Speaker',1);
            TDTpartag(AX,RUNTIME.TRIALS,'Speakers.Switch_Speaker',0);
        end
        
        
        %Look at FASTRAK output and determine in which region the receiver is
        %pointed
        currentRegion = compareHeadings([x(5) x(6)],Headings,Tolerance);
        
        %Display the current region that the receiver is pointed at
        set(h.actualRegion,'String',num2str(x(5)));
        
        %Display the polar plot showing azimuth and elevation
        visualPolar4(h,x,Target,Headings,Tolerance);
        
        
        %whileCheck only allows data to be written to the GUI table once after the
        %while loop has terminated
        whileCheck = 0;
        
        %This while loop defines a trial
        while TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*RespWindow') && X == 0
            TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*StartTrial',0);
            
            %Turn lights on according to paradigm
            fprintf(LEDuino,'%d',LED_Sig);
            whileCheck = 1;
            
            %Get the data from FASTRAK
            x = pollFastrak_InTrial(FASTRAK,Azi,Ele);
            %cumulFASTRAK(end+1,:) = x;
            cumulFASTRAK = [cumulFASTRAK;x];
            
            %Change the azimuth and elevation readings from FASTRAK into
            %radians and display them on the two polar plots
            visualPolar4(h,x,Target,Headings,Tolerance);
            
            %When X == 1 then a region has been fixated on. fixedPoint is the
            %current region
            [X,fixedPoint] = checkDuration3([x(5) x(6) Tolerance(Target)], Headings(Target), initBuffSize);
            
            %Testing
            
        end
        
        %After a trial has been run this set of if statements can occur
        if whileCheck == 1
            checkFixate3([90 90],fixateTime,Tolerance(Target));
            checkDuration3([0 0 0], 99, 5);
            
            %If a point had been fixated on for long enough
            if X == 2
                %This defines a hit
                TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*CORRECT',1);
                currentTrial = [Headings(Target) fixedPoint 1 1];
                %Fixated on the wrong region
            elseif X == 1
                TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INCORRECT',1);
                currentTrial = [Headings(Target) fixedPoint 0 1];
            %No region fixated on for long enough or looked out of bounds for
            %the duration of the response window
            else
                TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INCORRECT',1);
                currentTrial = [Headings(Target) nan 0 1];
            end
        end
    catch me
        %Troubleshooting
        disp('ERROR')
    end
    
    %Reset the CORRECT and INCORRECT parameters going into RPvds
    TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*CORRECT',0);
    TDTpartag(AX,RUNTIME.TRIALS,'Behaviour.*INCORRECT',0);
%     AX.SetTagVal('*CORRECT',0);
%     AX.SetTagVal('*INCORRECT',0);
    
    
    
    
    
    % escape until a new trial has been completed
    if ntrials == lastupdate,  return; end
    lastupdate = ntrials;
    
    
    RUNTIME.TRIALS.HeadTracker(length(RUNTIME.TRIALS.DATA)).DATA = cumulFASTRAK;
    cumulFASTRAK = [];
    % copy DATA structure to make it easier to use
    DATA = RUNTIME.TRIALS.DATA;
    
    % Use Response Code bitmask to compute performance
    %RCode = [DATA.ResponseCode]';
    
    %HITS = bitget(RCode,3);
    %MISSES = bitget(RCode,4);
    %NORESP = bitget(RCode,10);
    
    %Retrieve the data from the GUI table to add the newest trial to the
    %beginning
    pastData = get(h.pastTrials,'data');
    
    %Troubleshooting
    %disp('Sending data to table')
    
    %In the first trial, the new data is presented as the only row in the table
    if ntrials == 1
        set(h.pastTrials,'data',currentTrial(1:3),'ColumnName',{'Target','Fixed','Hit?'});
        %In any trial after the first the new data is added to the top of the
        %table
    else
        set(h.pastTrials,'data',cat(1,currentTrial(1:3),pastData),'ColumnName',{'Target','Fixed','Hit?'},'RowName',fliplr(1:(ntrials)));
    end
    
    
catch me
    % good place to put a breakpoint for debugging
    
    rethrow(me)
end

function BoxTimerError(~,~)
global FASTRAK
if ~isempty(FASTRAK) && isa(FASTRAK,'serial') && isequal(FASTRAK.Status,'open')
    fclose(FASTRAK);
%     delete FASTRAK
    clear global FASTRAK
end


function BoxTimerStop(~,~)
global FASTRAK motorBox LEDuino

fclose(motorBox);
% delete motorBox
clear global motorBox

fprintf(LEDuino,'%d',0);

fclose(LEDuino);
% delete LEDuino
clear global LEDuino

if ~isempty(FASTRAK) && isa(FASTRAK,'serial') && isequal(FASTRAK.Status,'open')
    fclose(FASTRAK);
%     delete FASTRAK
    clear global FASTRAK
end













