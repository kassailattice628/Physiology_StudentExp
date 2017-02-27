function h = PlotHist(var, n, th, rectime, weight)
% Plot raw trace and Histogram, with rectime/10 sec bin width).
% var: name of cell variable ('savedata')
% n: trial number to show
% th: spike threshold (mV), 300~1000 ?
% rectime: recording time. rectime/10 is used for bin wdith.
% weight: number or string, if this parameters is set, PDF file of the plot
% is saved in the working directry.

switch nargin
    case 5
        if isnumeric(weight)
            weight = num2str(weight);
        end
    case 4
        weight =  '' ;
end
%data
t = var{n}(:,1);
y = var{n}(:,2);

%find spikes
[~,ind] = findpeaks(y,'MinPeakHeight',th, 'MinPeakDistance',20);


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