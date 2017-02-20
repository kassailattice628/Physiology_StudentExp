function PlotRaw(var, n)
%Plot raw data
%var: saved variable (cell)
%n: # of var's row which you wnat to see the trace
%

figure

t = var{1,n}(:,1);
d = var{1,n}(:,2);

plot(t, d)
xlim([t(1), t(end)])