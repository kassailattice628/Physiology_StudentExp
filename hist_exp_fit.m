function hist_exp_fit(h, t1, t2)
% h = histogram

%x-data
t_hist = h.BinEdges(1:length(h.BinCounts))';
%y-data
y_hist = h.BinCounts';

%t1-t2 range
t_i = find(t_hist >= t1 & t_hist <= t2);

t_hist = t_hist(t_i);
y_hist = y_hist(t_i);

t0 = t_hist(find(t_hist > t1, 1, 'first'));
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0, 0.01, 0],...
    'Upper',[max(y_hist), 30, max(y_hist)],...
    'StartPoint',[10, 10, 0]);

ft = fittype('a*exp(-x/b)+c', 'options', fo);

y_fit = fit(t_hist - t0, y_hist, ft);
disp(y_fit);

t_fit = t1: 0.1: t2;
hold on
plot(t_fit, y_fit(t_fit-t1), 'r-', 'LineWidth', 1)
hold off


end