function BehaviorQuickPlot
%---Quickly plots behavior session data.
%Created 12/13/2018 JDY.

%1) Click Run ("Play" button)

clear all
close all
clc
%---Load Data---%
[f,p]           =	uigetfile;
file            =	[p f];
load(file)
D               =	extractfields(Data);
%---Organize Data---%
DATA            =	GetData(D);
PelletCount     =   D(end).Pellet;
disp(['Pellet Count = ' num2str(PelletCount)])
%---Plot Data Overview---%
PlotFunctions(DATA);

%---Locals---%
function d = extractfields(Data)
N				=	length(Data);
for i=1:N
	d(i).Reminder		=	Data(i).Reminder;
	d(i).ResponseCode	=	Data(i).ResponseCode;
	d(i).AMrate			=	Data(i).AMrate1;
	d(i).TrialType		=	Data(i).TrialType;
	d(i).RespLatency	=	Data(i).RespLatency;
    d(i).StimDur        =   Data(i).Stim1_Dur;
    d(i).ModDur         =   Data(i).ModDur;
    d(i).Pellet         =   Data(i).PelletCount;
%     d(i).LEDDelay       =   Data(i).LED_Delay;
end

function DATA = GetData(Data)
D						=	Data;
N						=	length(D);
% RespLegend				=	Info.Bits;
% Resp					=	nan(N,1);			%---1:Hit; 2:Miss; 3:CR; 4:FA---%
Rate					=	nan(N,1);		
Trial					=	nan(N,1);			%---0:Left; 1:Right---%
Lat						=	nan(N,1);
for a=1:N
	dat					=	D(1,a);
% 	if( Ephys )
% 		remind(a,1)		=	dat.Behavior_Reminder;
% 	else
		remind(a,1)		=	dat.Reminder;
% 	end
    RespCode            =   getRespCode(dat.ResponseCode);
	Resp(a,1)			=	RespCode;
	Rate(a,1)			=	dat.AMrate;
    ModDur(a,1)         =   dat.ModDur;
% if( Ephys )
% 	Trial(a,1)			=	dat.Behavior_TrialType;
% 	Lat(a,1)			=	dat.Behavior_RespLatency;
% else
	Trial(a,1)			=	dat.TrialType;
	Lat(a,1)			=	dat.RespLatency;
    
    pellets(a,1)        =   dat.Pellet;
% end
end
DATA					=	[Trial Rate ModDur Resp Lat];
rel						=	remind == 0;
DATA					=	DATA(rel,:);

function RespCode = getRespCode(ResponseCode)
if( ResponseCode == 165 || ResponseCode == 201 ) %---Hit---%
    RespCode    =   1;
end
if( ResponseCode == 198 || ResponseCode == 170 ) %---Miss---%
    RespCode    =   2;
end
if( ResponseCode == 4 || ResponseCode == 8 )     %---Hang---%
    RespCode    =   3;
end
if( ResponseCode == 148 || ResponseCode == 152 ) %---Abort---%
    RespCode    =   4;
end

function PlotFunctions(DATA)
Rates			=	unique(DATA(:,2));
ModDur          =   unique(DATA(:,3));
NRates			=	length(Rates);
NDur            =   length(ModDur);

pHits			=	nan(NRates,1);
N				=	nan(NRates,1);

for i=1:NRates
	rate		=	Rates(i);
	sel			=	DATA(:,2) == rate;
    data		=	DATA(sel,:);
    Crates(i,1) =   {num2str(rate)};
    
    for j=1:NDur
        
        N(i,j)		=	sum(sel);
        
        hel			=	data(:,4) == 1;
        phits		=	sum(hel)/length(hel);
%         Lat(i,j)	=	{data(hel,end)};
        pHits(i,j)	=	phits;
        
        Cdur(i,j)   =   {[ num2str(rate) ' Hz ' num2str(ModDur(j)) ' ms']};
    end
end

disp(['Rate' Cdur'])
disp(['N = ' num2str(N')])
disp(['Hit Rate = ' num2str(pHits')])

% T=table(pHits,'RowNames',Crates)
% Num=table(N,'RowNames',Crates)


