function PlotAFCTempIntegration_Overview
clear all
close all
clc

%---RIGHT---%
X       =   [100 200 600 800 1000; 200 400 600 800 1000; 100 300 600 800 1000];
Y       =   [42.8571 84.6154 86.3636 91.6667 85.2941; 46.6667 78.5714 76 92	90.3226; 50 80 93.3333 88.5714 88.8889];
figure(1)
subplot(1,2,1)
plotdata(X,Y)

X       =   [100 200 600 800 1000; 100 200 400 600 1000; 100 300 600 800 1000];
Y       =   [61.5385 56.25 100 90 94.1176; 50 63.6364 76.9231 90 93.75; 66.6667	68.75 94.7368 89.2857 86.3636];
figure(1)
subplot(1,2,1)
plotdata(X,Y,1)

%---Locals---%
function plotdata(X,Y,type)
if nargin < 3
    type    =   0;
end
N       =   size(X,1);

for i=1:N
    
   x    =   X(i,:);
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

