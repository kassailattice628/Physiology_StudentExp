function PlotHist(var, n, th, rectime, weight)
% Plot raw trace and Histogram, with rectime/10 sec bin width).
% var: name of cell variable ('savedata')
% n: trial number to show
% th: spike threshold (mV), 300~1000 ?
% rectime: recording time. rectime/10 is used for bin wdith.
% weight: number or string, if this parameters is set, PDF file of the plot
% is saved in the working directry.
 xd   g
switch nargin
    case 5
        if isnumeric(weight)
            weight = num2str(weight);
        end
    case 4
        weight =  '' ;
end

%data
if iscell(var)
    t = var{n}(:,1);
    y = var{n}(:,2);
else
    t = var(:,1);
    y = var(:,2);
end

%find spikes
[~,ind] = findpeaks(y,'MinPeakHeight',th, 'MinPeakDistance', 20, 'MaxPeakWidth', 30, 'MinPeakWidth', 10) ;
%slope check (threshold * 0.8 mV/ 0.5ms)

%{
ind2 = ind1 - 0.3*30000/1000; % 0.5ms before peak
slope = y(ind1) - y(ind2);
ind = ind1(slope > th*0.8);
%}

%% paper settings
figure;

width = 1024;
height = 768;
set(gcf, 'PaperPositionMode', 'auto')
pos = get(gcf, 'Position');
pos(3) = width-1;
pos(4) = height;
set(gcf, 'Position', pos, 'PaperOrientation','landscape');

%% plot raw data
subplot(2,1,1)
plot(t, y);
xlim([t(1), t(end)]);
hold on;
plot(t(ind), th, 'm*');
hold off
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%% histogram
subplot(2,1,2)

binw = rectime*5; % binned with 100 ms
h = histogram(t(ind), binw); 
xlim([t(1), t(end)]);
ax = gca;
outerpos = ax.OuterPosition;
bottom = outerpos(2) + ti(2);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%% Fitting
%{
bint = (t(1):0.1:t(end))';
biny = h.Values';
hold on
%plot(bint,biny, 'gx');
offset =  mean(biny(end-100:end));
f = fit(bint(1:3:99), biny(1:3:99)-offset,'exp1');
%}
hold off

%% savefig
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

if nargin ==  5
    title(['Weight = ', weight, ' g']);
    print(fig,['Histogram_',weight],'-dpdf')
end

end