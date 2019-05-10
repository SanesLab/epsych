function PlotAFCTempIntegration_Overview_v2
clear all
% close all
clc

%---RIGHT---%
X       =   [200 400 600 800 1000];
Y       =   [50	63.1579	90	81.25 90.9091; 54.5455 88.2353 92.3077 87.5	83.871; 58.3333	80 87.5	95.2381	91.6667];
figure(1)
subplot(1,2,2)
plotdata(X,Y)
%---LEFT---%
X       =   [200 400 600 800 1000];
Y       =   [41.6667 86.6667 100 77.7778 80.8511; 50 82.3529 91.6667 90.4762 86.6667; 41.6667 64.2857 80 91.3043 81.8182];
figure(1)
subplot(1,2,2)
plotdata(X,Y,1)

%---Locals---%
function plotdata(X,Y,type)
if nargin < 3
    type    =   0;
end
N       =   size(Y,1);

for i=1:N
    
   x    =   X;
   if( type == 1 )
       x    =   -(x);
   end
   y    =   Y(i,:);
   
   plot(x,y,'k-','LineWidth',3)
   hold on
   
end
set(gca,'FontSize',20)
set(gca,'XTick',[-1000 -600 -300 -100 0 100 300 600 1000],'XTickLabel',[1000 600 300 100 0 100 300 600 1000])
% set(gca,'xscale','log')
xlabel('modulation duration (ms)')
ylabel('Hit Rate (%)')
axis square
xlim([-1100 1100])
ylim([40 101])
plot([0 0],[0 110],'k-','Color',[0.50 0.50 0.50])
