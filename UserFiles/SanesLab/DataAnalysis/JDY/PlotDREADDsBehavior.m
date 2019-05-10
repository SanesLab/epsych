function PlotDREADDsBehavior
clear all
close all
clc

ID      =   '265045';
AMRate  =   [4.5 6 8 10 12];
DP(1,:) =   [0.9892	1.8308	2.2983	2.5233	2.0567];
DP(2,:) =   [0	1.9581	1.5314	2.2678	2.2678];
DP(3,:) =   [NaN	0.6412	1.4508	1.9318	1.5415];
DP(4,:) =   [0	1.5839	1.8812	1.5673	2.0081];
DP(5,:) =   [0.4936	2.0938	2.4571	1.8323	2.1952];

figure(1)
subplot(1,2,1)
h       =   plot(AMRate',DP','-','LineWidth',2);
hold on
% plot(AMRate',DP','o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',2);
set(gca,'FontSize',20)
title('RightM: Bilateral PC')
set(gca,'XTick',AMRate,'XTickLabel',AMRate)
xlabel('AM Rate (Hz)')
ylabel('d-prime')
axis square
xlim([2.5 14])
ylim([0 3])
legend(h,'Baseline','CNO','C21','C21','Saline')
legend(h,'Location','SouthEast')
legend('boxoff')

ID      =   '2650457';
AMRate  =   [4.5 6 8 10 12];
DP(1,:) =   [0.839	1.736	2.2305	2.2305	2.2305];
DP(2,:) =   [0.5793	2.0442	2.0442	2.0442	2.0442];
DP(3,:) =   [0	1.606	2.0052	2.0302	2.0302];
DP(4,:) =   [0.8285	1.7557	2.1283	2.1799	2.1799];

figure(1)
subplot(1,2,2)
h       =   plot(AMRate,DP,'-','LineWidth',2);
hold on
plot(AMRate,DP,'o','MarkerSize',12,'MarkerFaceColor','w','LineWidth',2);
set(gca,'FontSize',20)
title('TailM: Bilateral AuD')
set(gca,'XTick',AMRate,'XTickLabel',AMRate)
xlabel('AM Rate (Hz)')
ylabel('d-prime')
axis square
xlim([2.5 14])
ylim([0 3])
legend(h,'Baseline','CNO','C21','Saline')
legend(h,'Location','SouthEast')
legend('boxoff')