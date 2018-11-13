function PlotWeightResp(w1, maxFR1, w2, maxFR2) 

figure

semilogx(w1, maxFR1, 'ko')
hold on
semilogx(w2, maxFR2, 'rx')
hold off

%
legend('1step', '2step', 'location', 'northwest')
title('Weigth vs. max Firing Rate (Group C)')
xlabel('Weigth (log(g))')
ylabel('Max Firing Rate (spikes/sec)')
