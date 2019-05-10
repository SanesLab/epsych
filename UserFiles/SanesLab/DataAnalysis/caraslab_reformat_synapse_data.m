function epData = reformat_synapse_data_yao()
%caras_lab_reformat_synapse_data
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
%   MLC 03/2019, based on reformat_tank_data_kp.

%% 


%Select block
FULLPATH = uigetdir('C:\DATA\TDT_Tanks','Select BLOCK to process');
PathFolders = regexp(FULLPATH,filesep,'split');
TANKNAME  = PathFolders{end-1};
BLOCKNAME = PathFolders{end};

[~,~,tokenindices] = regexp(BLOCKNAME,'-','split');
Subject = BLOCKNAME(1:(tokenindices(end-1)-1));


%Identify (or create) temporary directory for data
savedir = 'C:\Users\SanesAdmin\Desktop\CarasLabTemp\';
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

epData = TDTbin2mat(FULLPATH,'TYPE',{'epocs','streams'});


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


end




