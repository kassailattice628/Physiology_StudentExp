function [ind, h] = PlotHist2(th, t_start, weight, fit_range)
% Plot raw trace and Histogram, with rectime/10 sec bin width).
% th: spike threshold (mV), if vector([lower, upper]), you can limt the
% range.
% weight: Tested weight (number or string (g)).
% if this parameter is set, figure is saved as PDF.

% fit_range: [t1, t2], used as a time range for exponential fit
% if you want to fit more than one range, 
% set fit_rage like [t1_1, t1_2; t2_1, t2_2];
%%
%bin width (ms) for PSTH
binw = 100;

if isnumeric(weight)
    weight = num2str(weight);
    disp(['Weight = ', weight, ' g'])
    
elseif isempty(weight)
    weight =  '' ;
    disp('No Weight info')
end

%% select data, t:Time, y:Signal
var = evalin('base','captureData');
t = var(:,1);
y = var(:,2);

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


%% Highpass filter ’¼‚·
sampt = t(2)-t(1);
Fs = 1/sampt;

%bandpass
[b,a] = butter(4, [300/(Fs/2), 3000/(Fs/2)]);
y = filtfilt(b,a,y);

%% Peak detection

%Min Peak Distance (point)
mpd = 1/1000 * Fs;
if length(th) == 1
    %[~,ind_min] = findpeaks(y,'MinPeakHeight',th, 'MinPeakProminence', th*0.8);% 'MinPeakDistance', 10, 'MaxPeakWidth', 30);
    
    %MinPeakHeight: minimum peal amplitude
    %MinPealProminence: prominence=amplitude from the baseline
    %Min-MaxPeakDistance: point??
    
    [~,ind_min] = findpeaks(y, 'MinPeakHeight',th, 'MinPeakDistance', mpd);
    ind1 =  ind_min;
elseif length(th) ==  2
    [~,ind_min] = findpeaks(y, 'MinPeakHeight',th(1), 'MinPeakDistance', mpd);
    [~,ind_max] = findpeaks(y, 'MinPeakHeight',th(2), 'MinPeakDistance', mpd);
    ind1 = setdiff(ind_min, ind_max);
end

%% slope check ( (threshold * 0.8)mV / 0.5ms)
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
xlabel('Time (s)')
ylabel('Voltage (mV)')
title('Response to skin extension')

hold on
%% detected spikes
plot(t(ind), th(1), 'm.');
hold off

%% histogram
subplot(2,1,2)

% t(sec), binw(msec)
nbin = round((t(end) - t(1))/binw*1000);
h = histogram(t(ind), nbin);
xlim([t(1), t(end)]);
xlabel('Time (s)')

%% fit
for i = 1:size(fit_range, 1)
    hist_exp_fit(h, fit_range(i, 1), fit_range(i, 2))
end
    
%% Save figure as pdf
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];


title(['Weight = ', weight, ' g']);
print(fig,['Histogram_',weight],'-dpdf', '-fillpage')
%print(fig,['Histogram_',weight],'-dpdf')

end