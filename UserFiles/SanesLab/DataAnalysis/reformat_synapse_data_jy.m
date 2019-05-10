function epData = reformat_synapse_data_jy()
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
 
%---FLAG---%
% OnTask      =   0;
prompt      =   {'On-Task Session? (1 = Yes; 0 = No)'};
dlgtitle    =   'FLAG';
dims        =   [1 35];
definput    =   {'1'};
OnTask      =   inputdlg(prompt,dlgtitle,dims,definput);
OnTask      =   str2double(OnTask);
tStart      =   tic;
%%
%Select block
FULLPATH = uigetdir('D:\data\TDT_Tanks','Select BLOCK to process');
PathFolders = regexp(FULLPATH,filesep,'split');
TANKNAME  = PathFolders{end-1};
BLOCKNAME = PathFolders{end};

% Check that savedir exists
[~,~,tokenindices] = regexp(BLOCKNAME,'-','split');
Subject = BLOCKNAME(1:(tokenindices(end-1)-1));

%Identify (or create) temporary directory for data
savedir = 'C:\Users\SanesAdmin\Desktop\JY_toTransfer\';
savedir = fullfile(savedir,TANKNAME,Subject);
if ~exist(savedir,'dir')
   mkdir(savedir);
end

%Check if datafile is already saved, and if so, ask user what to do.
savefilename = [savedir filesep BLOCKNAME '.mat'];
if exist(savefilename,'file')
    reply = '';
    while isempty(reply)
        reply = input('\n Reformated file exists already. Do you want to overwrite?\n Y/N:','s');
        
        switch reply
            case {'n','N','no','No','NO'}
                return
            case {'y','Y','yes','Yes','YES'}
                break
        end
    end
end



%% REFORMAT BLOCK DATA

fprintf('\n======================================================\n')
fprintf('Processing ephys data, %s.......\n', BLOCKNAME)

epData = TDTbin2mat(FULLPATH);


%% Find the associated behavior file if it exists
subject             =   Subject(end-5:end);
if( OnTask )
    path_BehFile        = fullfile(PathFolders{1:2},'JDY','AFC Ephys Behavior/On-Task');
else
    path_BehFile        = fullfile(PathFolders{1:2},'JDY','AFC Ephys Behavior/Off-Task');
end
date_BehFile_format = datestr(datenum(epData.info.date,'yyyy-mmm-dd'));
behaviorfile        = dir(fullfile(path_BehFile, [subject '_' date_BehFile_format '*'] ));
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

%%
try
    fprintf('\nsaving...')
    save(savefilename,'epData','-v7.3')
    fprintf('\n~~~~~~\nSuccessfully saved datafile to drive folder.\n\t %s\n~~~~~~\n',savefilename)
catch
    warning('\n **Could not save file. Check that directory exists.\n')
    keyboard
end

%%
% Automatically remove sev files from local harddrive (they still exist on
% the RS4)  --in order to prevent large synology backups
delete(fullfile(FULLPATH,'*.sev'))
%%

fprintf('\n\n ##### Finished reformatting and saving data files.\n\n')
tEnd = toc(tStart);
 fprintf('%d minutes and %f seconds\n', floor(tEnd/60), rem(tEnd,60));


end




