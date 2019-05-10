function PlotBehaviorResultsKLA
%---Script that analyzes behavior data from AM Rate Discrimination
%Task. This allows you to look at one behavior data file at a time,
%plotting the hit rate vs AM rate and the d-prime vs AM Rate. 

%Created 09/08/2017 JDY, modified by KLA 12/19/2017. 

%1) Click Run ("Play" button)

% clear all
% close all
% clc

%---Load Data---%  %uigetfile opens the file dialog box to select the data files
[filename,pathname]	= uigetfile('*.mat', 'Select datafile(s)', 'MultiSelect', 'on'); %can also shorten to "[f,p] = uigetfile" 
[filename,pathname]	= uigetfile('*mat', 'Select datafile'); 
file = [pathname filename]; %and here "[p f]" 
    load(file)
    D =	extractfields(Data);

% addpath('/Volumes/GoogleDrive/My Drive/Matlabfiles/BehaviorAnalysis/Kelsey_Behaviordatafiles/WWW (Males)/behavior files_withimplant');
% addpath('/Volumes/GoogleDrive/My Drive/Matlabfiles/BehaviorAnalysis/Kelsey_Behaviordatafiles/WWW (Males)');

%tail pre EP:
% myfiles = {'254877_30-Nov-2017.mat', '254877_07-Dec-2017.mat', '254877_13-Dec-2017.mat', '254877_13-Mar-2018.mat',... 
%         '254877_21-Mar-2018.mat', '254877_25-Mar-2018.mat', '254877_28-Mar-2018.mat', '254877_29-Mar-2018.mat'};

%tail during EP:     
% myfiles = {'254877_29-Mar-2018b.mat', '254877_30-Mar-2018.mat', '254877_31-Mar-2018.mat', '254877_02-Apr-2018.mat',... 
%          '254877_03-Apr-2018.mat', '254877_04-Apr-2018.mat', '254877_05-Apr-2018.mat',...
%         '254877_06-Apr-2018.mat', '254877_07-Apr-2018.mat', '254877_08-Apr-2018.mat', '254877_09-Apr-2018.mat', '254877_10-Apr-2018.mat'};
 
%neck pre EP: 
% myfiles = {'254881_30-Nov-2017.mat', '254881_01-Dec-2017.mat', '254881_04-Dec-2017.mat', '254881_05-Dec-2017.mat',... 
%         '254881_06-Dec-2017.mat', '254881_16-Jan-2018.mat', '254881_17-Jan-2018.mat', '254881_18-Jan-2018.mat',...
%         '254881_21-Jan-2018.mat', '254881_24-Jan-2018.mat'};

%neck during EP: 
% myfiles = {'254881_24-Jan-2018b.mat', '254881_25-Jan-2018.mat', '254881_26-Jan-2018.mat', '254881_27-Jan-2018.mat',... 
%         '254881_28-Jan-2018.mat', '254881_29-Jan-2018.mat', '254881_30-Jan-2018.mat', '254881_31-Jan-2018.mat',...
%         '254881_01-Feb-2018.mat', '254881_02-Feb-2018.mat', '254881_03-Feb-2018.mat', '254881_05-Feb-2018.mat'};

%neck post EP: 
%  myfiles ={'254881_05-Feb-2018b.mat', '254881_06-Feb-2018.mat', '254881_07-Feb-2018.mat' };

%fluffy pre EP: 
% myfiles = {'254882_01-Dec-2017.mat', '254882_05-Dec-2017.mat', '254882_18-Dec-2017.mat', '254882_22-Mar-2018.mat',... 
%         '254882_23-Mar-2018.mat', '254882_24-Mar-2018.mat', '254882_27-Mar-2018.mat', '254882_28-Mar-2018.mat', '254882_29-Mar-2018.mat'};

%fluffy during EP: 
% myfiles = {'254882_29-Mar-2018b.mat', '254882_30-Mar-2018.mat', '254882_31-Mar-2018.mat', '254882_01-Apr-2018.mat','254882_02-Apr-2018.mat',... 
%          '254882_03-Apr-2018.mat', '254882_04-Apr-2018.mat', '254882_05-Apr-2018.mat',...
%         '254882_06-Apr-2018.mat', '254882_07-Apr-2018.mat', '254882_08-Apr-2018.mat', '254882_09-Apr-2018.mat', '254882_10-Apr-2018.mat',...
%         '254882_11-Apr-2018.mat', '254882_12-Apr-2018.mat', '254882_13-Apr-2018.mat', '254882_15-Apr-2018.mat', '254882_16-Apr-2018.mat'};

%fluffy post EP: 
% myfiles = {'254882_16-Apr-2018b.mat', '254882_17-Apr-2018.mat', '254882_18-Apr-2018.mat', '254882_19-Apr-2018.mat','254882_02-Apr-2018.mat',... 
%          '254882_20-Apr-2018.mat', '254882_25-Apr-2018.mat', '254882_26-Apr-2018.mat', '254882_30-Apr-2018.mat'}; 

%left pre EP: 
% myfiles = {'254879_05-Dec-2017.mat', '254879_06-Dec-2017.mat', '254879_08-Dec-2017.mat', '254879_18-Jan-2018.mat',... 
%         '254879_19-Jan-2018.mat', '254879_21-Jan-2018.mat', '254879_22-Jan-2018.mat'};

% left during EP: 
% myfiles = {'254879_24-Jan-2018b.mat', '254879_25-Jan-2018.mat', '254879_26-Jan-2018.mat', '254879_27-Jan-2018.mat', '254879_28-Jan-2018.mat'}; 

%both pre EP: 
% myfiles = {'254880_06-Dec-2017.mat', '254880_07-Dec-2017.mat', '254880_11-Dec-2017.mat', '254880_28-Mar-2018.mat',... 
%         '254880_04-Apr-2018.mat', '254880_07-Apr-2018.mat', '254880_15-Apr-2018.mat'};

%both during EP: 
% myfiles = {'254880_15-Apr-2018b.mat', '254880_16-Apr-2018.mat', '254880_17-Apr-2018.mat', '254880_18-Apr-2018.mat', '254880_19-Apr-2018.mat',...
%             '254880_20-Apr-2018.mat', '254880_25-Apr-2018.mat', '254880_26-Apr-2018.mat'};

% myfiles = {'254880_16-Apr-2018.mat'}; 

% 
% for numfiles = 1:length(myfiles) 
%         load(myfiles{numfiles});
%         D =	extractfields(Data);
        
%---Organize Data---%
DATA		=	GetData(D,Info);
PlotFunctions(DATA);

end 


%---Locals---%
function d = extractfields(Data)
N				=	length(Data);
for i=1:N
	d(i).Reminder		=	Data(i).Reminder;
	d(i).ResponseCode	=	Data(i).ResponseCode;
	d(i).AMrate			=	Data(i).AMrate;
	d(i).AMdepth		=	Data(i).AMdepth;
	d(i).TrialType		=	Data(i).TrialType;
	d(i).RespLatency	=	Data(i).RespLatency;
end

function DATA = GetData(Data,Info)
D						=	Data;
N						=	length(D);
RespLegend				=	Info.Bits;
Resp					=	nan(N,1);			%---1:Hit; 2:Miss; 3:CR; 4:FA---%
Rate					=	nan(N,1);		
Trial					=	nan(N,1);			%---0:Go; 1:Nogo---%
Lat						=	nan(N,1);
Depth					=	nan(N,1);


for a=1:N
	dat					=	D(1,a);
	idx					=	nan(4,1);
% 	if( Ephys )
% 		remind(a,1)		=	dat.Behavior_Reminder;
% 	else
		remind(a,1)		=	dat.Reminder;
% 	end
	for b=1:4
		if( b == 1 ) % b == 1 returns a logical array with elements set to logical 1 (true) where arrays b and 1 are equal; otherwise, the element is logical 0 (false).
			if( isfield(RespLegend, 'hit') )
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.hit);
			else
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.Hit);
			end
		end
		if( b == 2 )
			if( isfield(RespLegend, 'miss') )
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.miss);
			else
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.Miss);
			end
		end
		if( b == 3 )
			if( isfield(RespLegend, 'cr') )
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.cr);
			else
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.CR);
			end
		end
		if( b == 4 )
			if( isfield(RespLegend, 'fa') )
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.fa);
			else
				idx(b,1)	=	bitget(dat.ResponseCode,RespLegend.FA);
			end
		end		
	end
	Resp(a,1)			=	find(idx,1);
	Rate(a,1)			=	dat.AMrate;
	Depth(a,1)			=	dat.AMdepth;
% if( Ephys )
% 	Trial(a,1)			=	dat.Behavior_TrialType;
% 	Lat(a,1)			=	dat.Behavior_RespLatency;
% else
	Trial(a,1)			=	dat.TrialType;
	Lat(a,1)			=	dat.RespLatency;
% end
end

DATA					=	[Trial Rate Resp Lat Depth];
rel						=	remind == 0;
DATA					=	DATA(rel,:);

disp ('   Animal ID')
disp (num2str(Info.Name)) 

disp (num2str(Info.Date)) 


function PlotFunctions(DATA)
gel				=	DATA(:,1) == 0;
Go				=	DATA(gel,:);
Rates			=	unique(Go(:,2));
% Depths			=	unique(Go(:,end));
NRates			=	length(Rates);

dp				=	nan(NRates,1);
pHits			=	nan(NRates,1);
Ngo				=	nan(NRates,1);
N				=	nan(NRates,1);

%---For Nogo stimuli---%
nel				=	DATA(:,1) == 1;
Nogo			=	DATA(nel,:);
fel				=	Nogo(:,3) == 4;
% pfa				=	sum(fel)/(length(fel)+0.50);
pfa				=	sum(fel)/(length(fel));
FAtrial			=	getFAacrosstrial(fel);
Nnogo			=	length(fel);

% save ('pfa') 
% if( pfa == 0 )
% % 	pfa			=	0.01;
% 	pfa			=	1/(2*length(fel));
% end
if( pfa < 0.05 )
	pfa			=	0.05;
end
pFA				=	repmat(pfa,NRates,1);

%---For Go stimuli---%
for i=1:NRates
	rate		=	Rates(i);
	nel			=	DATA(:,2) == rate;
	N(i,1)		=	sum(nel);
	sel			=	Go(:,2) == rate;
	Ngo(i,1)	=	sum(sel);
	data		=	Go(sel,:);
	hel			=	data(:,3) == 1;
% 	phits		=	sum(hel)/(length(hel)+0.50);
	phits		=	sum(hel)/length(hel);
	pH(i,1)		=	phits;
	if( phits > 0.95  )
		phits	=	0.95;
	end
	if( phits < 0.05  )
		phits	=	0.05;
	end
	pHits(i,1)	=	phits;

% 	if( phits == 1 )
% % 		phits	=	0.99;
% 		phits	=	1 - (1/(2*length(hel)));
% 	end
	dp(i,1)		=	calculatedprime(phits,pFA(i));
end
pfa				=	dround(pfa)*100; %false alarm rate 
zel				=	dp < 0;
dp(zel)			=	0;

subplot(1,2,1)
psychometricfunction(Rates,pHits,'ko','Hit Rate')

subplot(1,2,2)
psychometricfunction(Rates,dp,'ko','dprime')
legend('Session 1', 'x', 'x', 'Session 2', 'x', 'x', 'Session 3', 'x', 'x','Session 4', 'x', 'x','Session 5', 'x', 'x','Session 6', 'x', 'x','Session 7','x', 'x', 'Session 8','x', 'x', 'Session 9','x', 'x', 'Session 10','x', 'x', 'Session 11')

% hits		=	[Rates pH*100]; %original format 
% dp			=	[Rates dp];
hits		=	[Rates
                pH*100
                dp];


disp('Rates     Hit Rate    dprime')
disp(num2str(hits))

% disp('d-prime')
% disp(num2str(dp))

disp('FA Rate')
disp(num2str(pfa))

% New_Data_Matrix = [pfa]; 
% disp('compiled')
% disp New_Data_Matrix 
% save('New_Data_Matrix.mat')

 %%%I was trying to create a matrix where each iteration of the for loop goes through each datafile, grabs the FA rate,
% and stores it as new row. 
% 
% if exist('testytest.mat', 'file') 
%     
% FAratesnew = [];      
% FAratesnew = num2str(pfa);
% 
% % disp('compiled FA rates i hope')
% % disp(FAratesnew)
% save('testytest.mat','FAratesnew') %trying to grab the FA info before it is cleared from the workspace
% 
% else 
% m = matfile('testytest.mat','Writable',true);
%  FAratesnew(end+1) = num2str(pfa);
% end 

function dprime = calculatedprime(pHit,pFA)
zHit	=	sqrt(2)*erfinv(2*pHit-1);
zFA		=	sqrt(2)*erfinv(2*pFA-1);
% zHit	=	norminv(pHit,0,1);
% zFA		=	norminv(pFA,0,1);
%-- Calculate d-prime
dprime = zHit - zFA;

function FAtrial = getFAacrosstrial(fel)
N			=	length(fel);
FAtrial		=	nan(N,1);
for i=1:N
	fa		=	fel(1:i);
	pfa		=	sum(fa)/length(fa);
	FAtrial(i,1)	=	pfa;
end


%---Plotting Functions---%
function psychometricfunction(X,Y,mark,yLabel)
% plot(X,Y,'b-','LineWidth',3)
plot(X,Y,'LineWidth',3)
hold on
plot(X,Y,mark,'MarkerSize',10,'MarkerFaceColor','k','LineWidth',2)
if( strcmp(yLabel,'Hit Rate') )
	maxy	=	1.05;
	ylim([0 maxy])
	set(gca,'YTick',0:0.50:1,'YTickLabel',0:0.50:1);
	ylim([0 1])
else
	maxy	=	3.1;
	ylim([0 maxy])
	plot([0 50],[1 1],'k--','Color',[0.50 0.50 0.50])
	set(gca,'YTick',0:1:3,'YTickLabel',0:1:3);
	ylim([-0.10 3.1])
end
set(gca,'FontSize',20)
set(gca,'XTick',X,'XTickLabel',X)
xlabel('AM Rate (Hz)')
ylabel(yLabel)
axis square
xlim([0 16])   
% title (num2str(Info.Name)) 



