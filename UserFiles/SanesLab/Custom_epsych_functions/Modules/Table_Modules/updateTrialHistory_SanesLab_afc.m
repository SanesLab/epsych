function handles = updateTrialHistory_SanesLab_afc(handles,variables,reminders,HITind,GOind,NOGOind)
%handles = updateTrialHistory_SanesLab(handles,variables,reminders,HITind,FAind,GOind)
%
%Custom function for SanesLab epsych
%
%This function updates the GUI Trial History Table. For each GO trial type,
%d' values are calculated separately using the corresponding NOGO trial
%type. For example, if there are two NOGO trial types (optogenetic stim ON
%or OFF, both unmodulated noise) and there are multiple GO trial types
%(optogenetic stimuluation ON or OFF, with varying AM depths), each GO will
%be paired up with the appropriate NOGO (optogenetic stim ON or OFF,
%respectively) for calculating the d' value. Note that currently, the
%usability of this function is limited.  It has not been tested for NOGO
%trial types that differ in multiple dimensions, nor has it been tested for
%situations where the GO trials do not have a corresponding NOGO trial. Use
%with caution, and edit as needed.
%
%Inputs:
%   
%   handles: GUI handles structure
%   variables: matrix of trial information
%   reminders:
%   HITind: logical index vector for HIT responses
%   FAind: logical index vector for FA responses
%   GOind: numerical (non-logical) index vector for GO trials
%
%
%
%Written by ML Caras 7.28.2016

global RUNTIME 

%Only continue if at least one go trial has been presented
if isempty(GOind)
    return
end

%Find unique trials
data = [variables,reminders];
unique_trials = unique(data,'rows');

%Determine trial type column index for the trial history table
colnames = get(handles.TrialHistory,'ColumnName');
colind = find(strcmpi(colnames,'TrialType'));
colremind = find(strcmpi(colnames,'Reminder'));

%Pull out go and nogo trials
go_trials = unique_trials(unique_trials(:,colind) == 0,:);
nogo_trials = unique_trials(unique_trials(:,colind) == 1,:);

%Determine the total number of presentations and hits for each go trialtype
numgoTrials = zeros(size(go_trials,1),1);
numHits = zeros(size(go_trials,1),1);
for i = 1:size(go_trials,1)
    numgoTrials(i) = sum(ismember(data,go_trials(i,:),'rows'));
    numHits(i) = sum(HITind(ismember(data,go_trials(i,:),'rows')));
end
%Calculate hit rates for each trial type
hitrates = 100*(numHits./numgoTrials);
%Append extra data columns for GO trials
go_trials(:,end) = numgoTrials; %n Trials
go_trials(:,end+1) = hitrates; %hit rates

%Determine the total number of presentations and hits for each nogo trialtype
numnogoTrials = zeros(size(nogo_trials,1),1);
numnogoHits = zeros(size(nogo_trials,1),1);
for i = 1:size(nogo_trials,1)
    numnogoTrials(i) = sum(ismember(data,nogo_trials(i,:),'rows'));
    numnogoHits(i) = sum(HITind(ismember(data,nogo_trials(i,:),'rows')));
end
%Calculate hit rates for each trial type
hitrates2 = 100*(numnogoHits./numnogoTrials);

%Append extra data columns for NOGO trials
nogo_trials(:,end) = numnogoTrials; %n Trials
nogo_trials(:,end+1) = hitrates2;

all_trials = [go_trials;nogo_trials];

%Create cell array
D =  num2cell(all_trials);

%Update the text of the datatable
GOind = find([D{:,colind}] == 0);
NOGOind = find([D{:,colind}] == 1);
REMINDind = find([D{:,colremind}] == 1); %#ok<FNDSB>

D(GOind,colind) = {'RIGHT/DIFF'}; %#ok<FNDSB>
D(NOGOind,colind) = {'LEFT/SAME'}; %#ok<FNDSB>
D(REMINDind,colind) = {'REMIND'}; %#ok<FNDSB>

%Special case: if "expected" is a parameter tag
if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(handles.dev).tags,'Expected')))
    
    expectind = find(strcmpi(colnames,'Expected'));
    YESind = find([D{:,expectind}] == 1);
    NOind = find([D{:,expectind}] == 0);
    
    if ~isempty(expectind)
        D(YESind,expectind) = {'YES'}; %#ok<FNDSB>
        D(NOind,expectind) = {'NO'}; %#ok<FNDSB>
    end
    
end

set(handles.TrialHistory,'Data',D)

