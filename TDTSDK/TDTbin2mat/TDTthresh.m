function data = TDTthresh(data, STREAM, varargin)
%TDTTHRESH  TDT snippet extractor.
%   data = TDTthresh(DATA, STREAM, 'parameter', value, ...), where DATA is
%   the output of TDTbin2mat, STREAM is the name of the stream store to 
%   convert to snippets, and parameter value pairs define the snippet
%   extraction conditions. There are two possible extraction methods:
%
%       1) In 'manual' mode, extract snippets of length NPTS from all
%       channels in data.streams.(STREAM).data where the given THRESHOLD is
%       crossed. 1/4 of the waveform occurs before the threshold crossing.
%
%       2) In 'automatic' mode, extract snippets of length NPTS using a
%       threshold that automatically adjusts to changes in each channel's
%       baseline noise floor. The previous TAU seconds of data are used in
%       the calculation. The baseline noise floor is multiplied by the STD
%       parameter to set the current threshold.
%
%   output.snips.Snip    contains all snippet store data (timestamps, 
%                        channels, raw data, and sampling rate)
%
%   'parameter', value pairs
%       'MODE'      string, threshold mode. Can be 'automatic' or 'manual'
%                       (default = 'manual')
%       'NPTS'      scalar, number of points per snippet (default = 30)
%       'TETRODE'   bool, treat groups of four channels as a tetrode. If 
%                       true, a threshold crossing on one channel in the
%                       tetrode will trigger a snippet on all four channels
%                       in the tetrode (default = false) (TODO)
%       'THRESH'    scalar, absolute threshold for extracting snippets in
%                       'manual' mode (default = 100e-6). Can be negative
%                       for negative-first spike detection.
%       'REJECT'    scalar, defines artifact rejection level. If absolute
%                       value of candidate spike goes beyond this level, it
%                       is rejected (default = Inf)
%       'TAU',      scalar, defines size of moving window for 'automatic'
%                       thresholding mode, in seconds (default = 5)
%       'STD'       scalar, sets the number of standard deviations from the
%                       baseline noise floor to use as the threshold in
%                       'automatic' thresholding mode.
%       'POLARITY', scalar, set polarity for automatic threshold mode. Can
%                       be 1 or -1 (default = -1)
%       'OVERLAP',  bool, if true, multiple threshold crossings within one
%                       NPTS window are treated as distinct snippets
%                       (default = true)  (TODO)
%       'VERBOSE',  bool, set to false to disable console output
%                       (default = true)
%
%   Example
%      data = TDTbin2mat(BLOCKPATH);
%      data = TDTdigitalfilter(data);
%      data = TDTthresh(data, 'Wav1', 'MODE', 'manual', 'THRESH', 150e-6);
%      plot(data.snips.Snip.data')
%

data.snips.Snip = struct('data', [], 'chan', [], 'sortcode', [], 'ts', [], 'fs', 0);

% defaults
MODE       = 'manual';
POLARITY   = -1;
NPTS       = 30;
THRESH     = 100e-6;
TAU        = 0;
OVERLAP    = 1;
VERBOSE    = 1;
SNIP       = 'Snip';
REJECT     = Inf;

% parse varargin
for i = 1:2:length(varargin)
    eval([upper(varargin{i}) '=varargin{i+1};']);
end

if ~isfield(data, 'streams')
    error('no streams found in input data.')
end

if ~isfield(data.streams, STREAM)
    error('%s is not in data.streams.', STREAM)
end

if VERBOSE
    fprintf('window size is %d, ', NPTS);
    if OVERLAP
        fprintf('overlap is allowed.\n');
    else
        fprintf('without overlap.\n');
    end
end    

pre_wave = floor(NPTS/4)-1;
post_wave = NPTS - pre_wave-1;
[nchan, nsamples] = size(data.streams.(STREAM).data);
data.snips.(SNIP).fs = data.streams.(STREAM).fs;

if strcmp(MODE, 'manual')
    if VERBOSE
        fprintf('using absolute threshold method, set to %.2fuV.\n', THRESH*1e6);
    end
    thresh = THRESH;
    POLARITY = sign(THRESH);
else
    if VERBOSE
        fprintf('using automatic threshold method, with polarity %d, %.2f x std, and tau=%.2fs.\n', POLARITY, STD, TAU);
    end
    
    data.streams.DUMMY = data.streams.(STREAM);
    data.streams.DUMMY.data = sqrt(data.streams.DUMMY.data.*conj(data.streams.DUMMY.data));
    data = TDTdigitalfilter(data, 'DUMMY', 1/TAU, 'TYPE', 'low');
    thresh = STD*POLARITY*data.streams.DUMMY.data;
end
    
if POLARITY > 0
    [idx, idy] = find(data.streams.(STREAM).data >= thresh);
else
    [idx, idy] = find(data.streams.(STREAM).data <= thresh);
end

% can't have a crossing on the first sample
ind = idy==1;
idx(ind) = [];
idy(ind) = [];

% find indicies where crossing occurred
if POLARITY > 0
    if numel(thresh) == 1
        ind = find(data.streams.(STREAM).data(sub2ind([nchan, nsamples], idx, idy-1)) < thresh);
    else
        ind = find(data.streams.(STREAM).data(sub2ind([nchan, nsamples], idx, idy-1)) < thresh(sub2ind([nchan, nsamples], idx, idy-1)));
    end
else
    if numel(thresh) == 1
        ind = find(data.streams.(STREAM).data(sub2ind([nchan, nsamples], idx, idy-1)) > thresh);
    else
        ind = find(data.streams.(STREAM).data(sub2ind([nchan, nsamples], idx, idy-1)) > thresh(sub2ind([nchan, nsamples], idx, idy-1)));
    end
end
idy = idy(ind);
idx = idx(ind);

% can't have negative indicies, or indicies beyond the end of the waveform
ind = idy <= pre_wave | idy >= nsamples - post_wave;
idx(ind) = [];
idy(ind) = [];

if nchan == 1
    data.snips.(SNIP).chan = idx(1);
    idy = idy';
else
    data.snips.(SNIP).chan = int16(idx);
end

data.snips.(SNIP).ts = idy / data.snips.(SNIP).fs;

if strcmp(MODE, 'automatic')
    if VERBOSE
        fprintf('ignoring the first %.1f seconds\n', TAU)
    end
    ind = find(data.snips.(SNIP).ts < TAU);
    data.snips.(SNIP).ts(ind) = [];
    idx(ind) = [];
    idy(ind) = [];
end
% everything should already be sorted by time
%[data.snips.(SNIP).ts, sort_ind] = sort(data.snips.(SNIP).ts);
%data.snips.(SNIP).chan = data.snips.(SNIP).chan(sort_ind);

nwaves = numel(idy);
if nchan == 1
    idx = ones(NPTS*nwaves,1);
else
    idx = kron(idx, ones(NPTS,1));
end
idy = diag(idy) * ones( nwaves, NPTS) + repmat(-pre_wave:post_wave, nwaves, 1);
idy = reshape(idy', [], 1);
data.snips.(SNIP).data = reshape(data.streams.(STREAM).data(sub2ind([nchan, nsamples], idx, idy)), NPTS, nwaves)';

% remove artifacts
[x, y] = find(abs(data.snips.(SNIP).data) > REJECT);
remove = unique(x);
data.snips.(SNIP).data(remove,:) = [];
data.snips.(SNIP).ts(remove) = [];
data.snips.(SNIP).chan(remove) = [];

data.snips.(SNIP).sortcode = zeros(size(data.snips.(SNIP).ts), 'int16');
data.snips.(SNIP).name = SNIP;
data.snips.(SNIP).sortname = '';

