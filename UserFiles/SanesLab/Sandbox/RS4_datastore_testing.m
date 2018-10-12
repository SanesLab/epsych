

data1 = epData.streams.RSn1.data;
data2 = epData.streams.RSn1.data;

data = data1;

fs = epData.streams.RSn1.fs;
dur = size(data,2)/fs;

% seconds = [250:500];
% samples = round(seconds.*fs);

start = 4209000;
start = round((dur-300)*fs);


figure;
plot(data(11,start:end),'k')
ylim([-1 1].*2)
% xlim([0 seconds(end)-seconds(1)])


