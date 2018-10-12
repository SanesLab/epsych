function epData = reformat_synapse_data_kp()
%reformat_synapse_data_kp
%   Function to reformat and save ephys data from TDT.
%   
%   FIRST you must manually copy the .sev files from the appropriate folder
%   on the RS4 data streamer!
%   
%   Program prompts user to select a BLOCK (JUST ONE FOR NOW).
%   Then calls TDTbin2mat to reformat tank data to a matlab struct, and
%   saves as a -mat file in specified folder. 
%   
%   When finished, manually transfer these .mat files to Google Drive
%   and the tank to Synology Archive folder for backup, and then remove 
%   from local harddrive and from RS4.
%   
%   To do: 
%    - select multiple blocks
%   
%   KP 08/2018, based on reformat_tank_data.

% addpath helpers


%% 
[~,computerName] = system('hostname');

%Select block
switch computerName(1:6)
    case 'newreg'
        FULLPATH = uigetdir('C:\DATA\TDT_Tanks','Select BLOCK to process');
        savedir = 'C:\Users\SanesAdmin\Desktop\KP_toTransfer';
    case 'regina'
        FULLPATH = uigetdir('D:\data\KP','Select BLOCK to process');
        savedir = 'G:\NYUDrive\Sanes\DATADIR\AMJitter\RawData';
    case 'dhs-ri'
        FULLPATH = uigetdir('G:\KP\Tanks','Select BLOCK to process');
        savedir = 'G:\KP\toTransfer';
end

PathFolders = regexp(FULLPATH,filesep,'split');

TANKNAME  = PathFolders{end-1};
BLOCKNAME = PathFolders{end};


RS4PATH = fullfile('\\10.1.0.42\data',TANKNAME,BLOCKNAME);



% Check that savedir exists

[~,~,tokenindices] = regexp(BLOCKNAME,'-','split');
Subject = BLOCKNAME(1:(tokenindices(end-1)-1));

if ~exist(savedir,'dir')
    error('  Cannot find directory specified for data saving.')
end

% If a folder does not yet exist for this tank, make one.
savedir = fullfile(savedir,TANKNAME,Subject);
if ~exist(savedir,'dir')
    mkdir(savedir)
end

% Check if datafile is already saved. If so, skip it.
savefilename = [savedir filesep BLOCKNAME '.mat'];
if exist(savefilename,'file')
    fprintf('\n Reformated file exists already. Do you want to overwrite?\n')
    keyboard
end




%% REFORMAT BLOCK DATA

fprintf('\n======================================================\n')
fprintf('Processing ephys data, %s.......\n', BLOCKNAME)

epData = TDTbin2mat(FULLPATH);

% keyboard

%% Find the associated behavior file if it exists

path_BehFile        = fullfile(PathFolders{1:2},'MAT_Files','KP',Subject);
date_BehFile_format = datestr(datenum(epData.info.date,'yyyy-mmm-dd'));
behaviorfile        = dir(fullfile(path_BehFile, [Subject '_' date_BehFile_format '*'] ));
if isempty(behaviorfile)
    keyboard
end

for ib = 1:numel(behaviorfile)
    load(fullfile(path_BehFile,behaviorfile(ib).name))
    
    %ephys only, on days with no behavior recording
    if ~isfield(Info,'ephys')
        keyboard
        behaviorfile = [];
        break
        
        %if the Info file loaded matches this block
    elseif isfield(Info,'ephys') && strcmp(BLOCKNAME,Info.ephys.block)
        behaviorfile = behaviorfile(ib);
        break
    end
    
    %if this block was not saved as an entry in a Behavior Info file, it is ephys only.
    if ib==numel(behaviorfile)
        fprintf('\n this file ephys only\n')
        behaviorfile = [];
    end
end



%% Save buffer stimulus files/info

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~  AM aversive experiment  ~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Falling edge of InTrial
%  epData.epocs.RCod -- response code
%   17: hit
%   18: miss
%   36: CR
%   40: FA

% StimTrial TTL:
%  epData.epocs.TTyp --  0: Warn, 1: Safe
%  epData.epocs.Opto
%  epData.epocs.rVID --  rateVec_ID

% end of each AM period
%  epData.epocs.AMrt  =  instantaneous AM rate of period ending

% epData.streams.rVrt.data
%  (1,:) = Instantaneous AM rate
%  (2,:) = Sound output
%  (3,:) = AM depth
%  (4,:) = dB SPL
%  (5,:) = HP
%  (6,:) = LP
%  (7,:) = Spout TTL
%  (8,:) = ITI TTL
    
if isfield(epData.streams,'rVrt') && isfield(epData.epocs,'RCod') && isfield(epData.epocs,'AMrt')
    
    if ~isempty(behaviorfile) && exist('Info','var')
        
        % Get stimfiles from behavior file and save to epData
        epData.stimfs     = Info.stimfns;
        
        % Associate the behavior file with epData struct
        epData.info.fnBeh = behaviorfile.name;
        
        % Copy behavior file to external harddrive
        copyfile(fullfile(path_BehFile,behaviorfile.name),[savedir filesep BLOCKNAME '_behavior.mat'])
    end
    
    
end %filter experiment type



%%

% Remove field containing eNeu data to save a little space
if isfield(epData,'snips')
    epData = rmfield(epData,'snips');
end

try
    fprintf('\nsaving...')
    save(savefilename,'epData','-v7.3')
    fprintf('\n~~~~~~\nSuccessfully saved datafile to drive folder.\n\t %s\n~~~~~~\n',savefilename)
catch
    warning('\n **Could not save file. Check that directory exists.\n')
    keyboard
end






fprintf('\n\n ##### Finished reformatting and saving data files.\n\n')


end




