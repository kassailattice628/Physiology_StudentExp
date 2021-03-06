function [ind, h] =  PlotHist(var, n, th, binw, t_start, weight, showfit)
% Plot raw trace and Histogram, with rectime/10 sec bin width).
% var: name of data variable (cell or 2Dmatrix): e.g.) 'captureData', 'savedata', etc...
% n: trial number to show. if 2Dmatrix is selected, set n as 1.
% th: spike threshold (mV), if vector([lower, upper]), you can limt the
% range.
% binw: bin wdith for PSTH (ms).
% weight: Tested weight (number or string (g)).
% if this parameter is set, figure is saved as PDF.
% showfit: if showfit=1, Adaptation curve is estimated by exp decay curve
%% 
switch nargin
    case 6
        if isnumeric(weight)
            weight = num2str(weight);
            disp(['Weight = ', weight, ' g'])
        end
    case 5
        weight =  '' ;
        disp('No Weight info')        
end

%% select data, t:Time, y:Signal
if iscell(var)
    t = var{n}(:,1);
    y = var{n}(:,2);
else
    t = var(:,1);
    y = var(:,2);
end

%% offset baseline

t = t - t(1);
y = y - mean(y);

%% set start position
if isempty(t_start)
    ts_i = 1;
else
    ts_i = find(t < t_start, 1, 'last')+1;
end

t = t(ts_i:end);
y = y(ts_i:end);


%% Highpass filter
[b,a] = butter(4, [0.02 0.5]);
y = filtfilt(b,a,y);

%% Peal detection
if length(th) == 1
    [~,ind_min] = findpeaks(y,'MinPeakHeight',th, 'MinPeakProminence', th*0.8);% 'MinPeakDistance', 10, 'MaxPeakWidth', 30);%, 'MinPeakWidth', 10) ;
    ind1 =  ind_min;
elseif length(th) ==  2
    [~,ind_min] = findpeaks(y,'MinPeakHeight',th(1), 'MinPeakProminence', th(1)*0.8);%, 'MinPeakDistance', 10);%, 'MaxPeakWidth', 30);%, 'MinPeakWidth', 10) ;
    [~,ind_max] = findpeaks(y,'MinPeakHeight',th(2), 'MinPeakProminence', th(2)*0.8);%, 'MinPeakDistance', 10);%, 'MaxPeakWidth', 30);%, 'MinPeakWidth', 10) ;
    ind1 = setdiff(ind_min, ind_max);
end

%slope check ( (threshold * 0.8)mV / 0.5ms)
sampt = var(2,1) - var(1,1);
ind2 = ind1 - round(0.5/sampt/1000); % 0.5ms before peak

ind1 = ind1(ind2 > 0);
ind2 = ind2(ind2 > 0);

slope = y(ind1) - y(ind2);
ind = ind1(slope > th*0.8);

%%%%% plot %%%%%
figure;
%% plot raw data
subplot(2,1,1)
plot(t, y);
xlim([t(1), t(end)]);
hold on
%% detectedd spikes
plot(t(ind), th(1), 'm*');
hold off

%% histogram
subplot(2,1,2)

% t(sec), binw(msec)
nbin = round((t(end) - t(1))/binw*1000);
h = histogram(t(ind), nbin); 
xlim([t(1), t(end)]);

%% Fitting
if nargin == 7 && showfit == 1
        t_hist = h.BinEdges(1:length(h.BinCounts))';
        y_hist = h.BinCounts';
        
        % use 30 sec
        t_hist = t_hist(t_hist <= 20);
        y_hist = y_hist(t_hist <= 20);
        t0 = t_hist(1);
        fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0, 0.01, 0],...
               'Upper',[max(y_hist), 30, max(y_hist)],...
               'StartPoint',[10, 10, 0]);
           
        ft = fittype('a*exp(-x/b)+c', 'options', fo);
        y_fit = fit(t_hist - t0, y_hist, ft);
        disp(y_fit);
        t_fit = [0:0.1:30] + t0;
        hold on
        plot(t_fit, y_fit(t_fit-t0), 'r-')
        hold off
end
%% savefig
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

if nargin ==  6
    title(['Weight = ', weight, ' g']);
    %print(fig,['Histogram_',weight],'-dpdf', '-fillpage')
    print(fig,['Histogram_',weight],'-dpdf')
end

end