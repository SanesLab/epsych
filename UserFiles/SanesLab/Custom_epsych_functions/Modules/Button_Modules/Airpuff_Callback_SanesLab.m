function handles = Airpuff_Callback_SanesLab(handles)
%handles = Airpuff_Callback_SanesLab(handles)
%
%Custom function for SanesLab epsych
%
%This function triggers the airpuff when the Air Puff button is pressed
%Input:
%   handles: GUI handles structure
%
%Written by ML Caras May 1 2018


global AX RUNTIME

module = handles.module;
dev = handles.dev;
paramtag = 'AirPuff';

%Abort if airpuff parameter tag is not in the RPVds circuit
if sum(~cellfun('isempty',strfind(RUNTIME.TDT.devinfo(dev).tags,paramtag)))== 0
    return
end

%Use Active X controls to trigger the airpuff
v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],1);

%Use Active X controls to reset trigger
v = TDTpartag(AX,RUNTIME.TRIALS,[module,'.',paramtag],0);

end

