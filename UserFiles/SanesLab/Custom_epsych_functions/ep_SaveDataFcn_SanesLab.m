function ep_SaveDataFcn_SanesLab(RUNTIME)
% ep_SaveDataFcn_SanesLab(RUNTIME)
% 
% Sanes Lab function for saving behavioral data
%
% 
% Daniel.Stolzberg@gmail.com 2014. 
% Updated by ML Caras 2015.
% Updated by KP 2016. Saves buffer files and associated ephys tank number.
% Updated by ML Caras Apr 2018. Added Synapse compatibility.

global SYN_STATUS

datestr = date;
%For each subject...
for i = 1:RUNTIME.NSubjects
    %Subject ID
    ID = RUNTIME.TRIALS(i).Subject.Name;
    
    %Let user decide where to save file
    h = msgbox(sprintf('Save Data for ''%s''',ID),'Save Behavioural Data','help','modal');
    uiwait(h);
    
    %Default filename
    filename = ['C:\DATA\', ID,'_', datestr,'.mat'];
    fn = 0;
    
    %Force the user to save the file
    while fn == 0
        [fn,pn] = uiputfile(filename,sprintf('Save ''%s'' Data',ID));
    end
    
    fileloc = fullfile(pn,fn);
    
    %Save all relevant information
    Data = RUNTIME.TRIALS(i).DATA;
    
    Info = RUNTIME.TRIALS(i).Subject;
    Info.TDT = RUNTIME.TDT(i);
    Info.TrialSelectionFcn = RUNTIME.TRIALS(i).trialfunc;
    Info.Date = datestr;
    Info.StartTime = RUNTIME.StartTime;
    %%%%%%%%
    if( sum(~cellfun(@isempty,strfind(fieldnames(Data),'Food_TTL'))) < 1 ) 
        Info.Water = updatewater_SanesLab;  %This was giving me an error. will adjust later. 5/7/17 JDY/%
    end
    %%%%%%%%
    Info.Bits = getBits_SanesLab;
    
    try
    %Add WAV/MAT file names to Info struct if this experiment uses a buffer
    if any(~cellfun(@isempty,strfind(fieldnames(Data),'_ID')))          %kp
        
        if ~isfield(Data,'rateVec_ID'), keyboard, end
        
        rV_idx = strcmp(RUNTIME.TRIALS.writeparams,'rateVec'); %find index corresponding to data buffer for behavior-only sessions
        if ~any(rV_idx) %find index corresponding to data buffer for sessions using OpenEx
            rV_idx = strcmp(RUNTIME.TRIALS.writeparams,[RUNTIME.TDT.name{strcmp(RUNTIME.TDT.Module,'RZ6')} '.rateVec']);
        end
        stimfns = unique(cellfun(@(x) (x.file), RUNTIME.TRIALS.trials(:,rV_idx), 'UniformOutput', false ),'stable');
        stimfns(end+1) = stimfns(1);
        
        Info.stimfns = stimfns;
        
        %% Print average behavioral results
        
        % Retreive response code bits
        bits = getBits_SanesLab;
        bitmask = [Data.ResponseCode]';
        HITind  = logical(bitget(bitmask,bits.hit));
        MISSind = logical(bitget(bitmask,bits.miss));
        CRind   = logical(bitget(bitmask,bits.cr));
        FAind   = logical(bitget(bitmask,bits.fa));
        
        % Calculate hit rate
        HitRate = sum(HITind)/(sum(HITind)+sum(MISSind));
        
        % Calculate dprime
        CorrectedHitRate = HitRate;
        CorrectedHitRate(HitRate > .99) = .99;
        CorrectedHitRate(HitRate < .01) = .01;
        zhit = sqrt(2)*erfinv(2*CorrectedHitRate-1);
        
        FArate = sum(FAind)/(sum(FAind)+sum(CRind));
        FArate(FArate > .99) = .99;
        FArate(FArate < .01) = .01;
        
        zfa = sqrt(2)*erfinv(2*FArate-1);
        
        dprime = zhit - zfa;
        
        % Print the results
        fprintf('\nRESULTS\n  N GOs: %i \n  HR:    %i \n  d'':    %0.2f \n',...
            sum(HITind)+sum(MISSind), round(HitRate*100), dprime);
        
        
        
    end
    catch
        keyboard
    end
    
    %Associate an Block number if ephys (but not using synapse). If we're
    %running synapse, experimental info (user, experiment name, tank,
    %block) are all automatically appended to the file at the beginning of
    %the experiment.
    if RUNTIME.UseOpenEx && ~isempty(SYN_STATUS)
        BLOCK = input('Please enter the ephys BLOCK number associated with this behavior file.\n','s');
        Info.epBLOCK = ['Block-' BLOCK];
    end
    
    %Fix Trial Numbers (corrects for multiple calls of trial selection
    %function during session)
    for j = 1:numel(Data)
        Data(j).TrialID = j;
    end
    
    
    
    save(fileloc,'Data','Info')
    if exist(fileloc,'file')      %kp 2017-11 
        disp(['Data saved to ' fileloc])
    else
        warning('File not saved; try again!')
        keyboard
    end
    
    
end











