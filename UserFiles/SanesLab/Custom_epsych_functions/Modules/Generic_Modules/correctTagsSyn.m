function params = correctTagsSyn(params,mod)
%params = correctTagsSyn(params,mod)
%
%Correct parameter tag naming structure for compatibility with Synapse
%legacy mode.
%
%params is a cellstr array of either writeparams or readparams from the
%global structure CONFIG
%
%mod is a stt containing the name of the TDT module running in legacy mode
%
%Written by ML Caras Apr 8 2018

i = cellfun(@(x) regexp(x,'\.'), params, 'UniformOutput', false);

for p = 1:numel(params)
    pname = params{p}(i{p}+1:end);
    params{p} = [mod,'.',pname];
end